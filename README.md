# Kademlia DHT — Decentralised ML Experiment Store

A production-grade Kademlia distributed hash table implementation in Go, built as the foundation for a decentralized ML experiment coordination system. Motivated by the observation that centralized tools like Weights & Biases and MLflow break down for genuinely distributed research teams — a DHT-based results store enables experiment coordination without a central server, single point of failure, or shared authentication.

Validated across 1,000+ node simulated networks with configurable fault injection, packet dropout, latency, and partitions. Built during graduate studies in Distributed Computing (D7024E) at Luleå University of Technology, 2025.

## Research Motivation

Current ML experiment tracking tools assume centralization. When research teams are distributed across institutions, organizations, or geographies, this creates bottlenecks and trust problems. A Kademlia-based results store addresses this by:

- Storing experiment configs, hyperparameters, and results across a distributed hash table with no central authority
- Enabling teams to define and run experiments independently while sharing results through the DHT
- Providing fault tolerance by design — nodes can join and leave without data loss, and lookups succeed under significant dropout
- Eliminating single points of failure that make centralized tools fragile in collaborative research contexts

This repo is the DHT layer. The experiment schema and coordination protocol sit on top of it — see the [neuromorphic-rf-classification](https://github.com/stefanhoglund/neuromorphic-rf-classification) repo for an example of the experiment management framework this infrastructure was designed to support.

## Simulation Results

Validated under realistic failure conditions using a pluggable mock network:

- **Scale:** 1,000+ node emulation via `BuildMockCluster`
- **Fault injection:** configurable drop rate, silent drops, latency, jitter, and network partitions
- **Coverage:** ≥80% test coverage across the kademlia package
- **Key behaviors validated:** routing table convergence under dropout, store/get success rates under packet loss, opportunistic caching on value retrieval

```bash
# Run large cluster simulation with packet drops
go test ./internal/kademlia -run TestLargeCluster_StoreGet_UnderDrop -v
```

## Architecture

The implementation separates three concerns cleanly:

**Network layer** — pluggable transport abstraction:
- `UDPNetwork` — real UDP for production use
- `MockNetwork` — in-memory channels with drop rate, latency, jitter, and partition simulation for testing

**Routing** — `RoutingTable` with K-buckets (K=20) and XOR-distance ordering. Iterative `FIND_NODE` lookups follow standard Kademlia protocol.

**Storage and replication** — `StoreWithTimeout()` hashes data with SHA-1 and pushes to the K closest nodes. `Get()` issues `FIND_VALUE` with opportunistic local caching on hit.

**Concurrency** — receive loop runs in a goroutine. Waiter maps and value store protected by mutex/RWMutex throughout.

**Message types:** `PING`, `PONG`, `FIND_NODE`, `NODES`, `STORE`, `FIND_VALUE`, `VALUE`

## Build & Run

**Requirements:** Go 1.24+

```bash
make build
# or:
go build -o kademlia ./cmd

# Start a node
./kademlia start --listen :9000 -v --interactive

# Join an existing network
./kademlia start --listen :9001 --bootstrap 127.0.0.1:9000

# Use mock network for local testing
./kademlia start --listen :9002 --mock
```

### Interactive REPL

```text
> put hello world
OK key=<hexsha1> replicated=3
> get <hexsha1>
hello world
> ping 127.0.0.1:9000
PONG from 127.0.0.1:9000 id=... rtt=...
> exit
```

## Docker — 50+ Node Network

```bash
# Build image
docker build --no-cache -t kademlia:latest .

# Spin up 50+ node network
docker compose up -d --build --scale node=50

# Attach to interactive console
docker compose attach console
```

The Compose topology includes a bootstrap node, N generic nodes, and a console node for REPL interaction. Docker DNS resolves service names automatically — nodes address each other by service name within the compose network.

## Testing

```bash
# Run all tests with coverage report
go test -v ./internal/kademlia -covermode=atomic -coverpkg=./... -coverprofile=coverage.out
go tool cover -html=coverage.out

# Large cluster simulation
go test ./internal/kademlia -run TestLargeCluster_StoreGet_UnderDrop -v
```

Mock network options for test configuration:
```go
MockNetOptions{
    DropRate:    0.20,   // 20% packet loss
    SilentDrop:  true,   // drop without error
    MinLatency:  5ms,
    Jitter:      10ms,
}
```

## Implementation Status

| Milestone | Feature | Status |
|-----------|---------|--------|
| M1 | Network formation — PING/PONG, join, node lookups | ✅ |
| M2 | Object distribution — STORE, FIND_VALUE, replication | ✅ |
| M3 | CLI and interactive REPL | ✅ |
| M4 | Unit testing — 1000+ node mock, ≥80% coverage | ✅ |
| M5 | Docker/Compose containerisation | ✅ |
| M6 | Lab report | ✅ |
| M7 | Concurrency and thread safety | ✅ |

## Known Limitations

- Lookup concurrency factor α is currently 1 — increasing would improve convergence speed
- No persistent storage across restarts (in-memory only)
- No value expiration, refresh, or republish
- Security and NAT traversal out of scope

## License

MIT