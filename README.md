# pythia

A new search stretagy: flat seach strategy for hierachy (with binary search mentioned by the paper)

Make sure I understand the search strategies

Goal is to improve hierachy strategy, now flat has an advantage

Questions is doing bfs or dfs


## Search Space
* Search space is a data structure, provided during an offline profiling phase or learned by Pythia.
* A single distributed application can have multiple search spaces, each optimized for different search strategies.


## Hierarchical Search
### Search Space
1. A collection of unique workflow paths
2. Nodes represent tracepoints/events
3. Two types of edges: 1) happens-before relationship (may include hierarchical caller/callee relationship) 2) shortcuts (facilitate faster searching)

### Using Search Space
1. Match critical paths to search space

### Span
1. Semantically meaningful intervals
2. Typically have caller/callee relationship between them
3. Hierarchy between spans is stricly defined as happened before relationship 

### Strategy
1. Hierarchy is top-down: First enabling lowest granularity and most general spans, and at each cycle enabling more and more granular spans to narrow down performance problems.

### Flat
1. Does not use hierarchy but only happen-before relationship

### happen-before: system definition
hierachy: span inside span; caller/callee refers to spans

## Happens-Before Relationship

## Documentation Location
file:///Users/sir/Desktop/projects/target/doc/pythia/search/flat/index.html
