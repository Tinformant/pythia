# Pythia Hybrid Search

## 08/07 Meeting
- [ ] How is flat search adhering to the budget and would it be possible to replicate that in hierarchical search?  Would what the algorithm be and what are the drawbacks?  
- [ ] Technically, traces are comprised of “spans” (pairs of trace points labeled with _ENTRY and _EXIT) and annotations (just a single trace point denoting an important event). For the former, do the search strategies always turn on trace points in pairs?  

## TODO
- [x] Find where it is randomly searching
- [x] Understand why hierarchical search needs the common context
- [x] Implement hybrid search
- [ ] Three EventTypes in get_context?
    * Returns every "Entry" trace point
    * Only returns "Annotation" trace point if it is also the node of interest
    * Does not return "Exit" trace point
- [ ] Hybrid search threshold and budget?
- [ ] Testing

## Quotes by Emre
What I envisioned the new search strategy to be was: to follow what the hierarchical strategy is doing except when there are many candidate trace points in one level of the hierarchy, where we could split them like the flat search. According to what I saw, hierarchical search spends the most time on finding which tracepoint in a level is problematic and doesn't use the happens-before relationships like the flat search which would speed up this part of the search.

## On Hybrid Search
4: "The search strategies are provided a problematic group, and the number of trace points to enable."
* A new search stretagy: flat seach strategy for hierachy (with binary search mentioned by the paper)
* Make sure I understand the search strategies
* Goal is to improve hierachy strategy, now flat has an advantage
* Questions is doing bfs or dfs

## Search Space
* Search space is a data structure, provided during an offline profiling phase or learned by Pythia.
* A single distributed application can have multiple search spaces, each optimized for different search strategies.

## Hierarchical Search
### 4.1 Search Space
1. A collection of unique workflow paths
2. Nodes of the search space represent tracepoints/events
3. Two types of edges: 1) happens-before relationship (may include hierarchical caller/callee relationship) 2) optional shortcuts (facilitate faster searching)

**Hierachy**
1. Semantically meaningful intervals
2. Typically have caller/callee relationship between them
3. Hierarchy between spans is stricly defined as happened before relationship 

### 4.2 Using Search Space
1. At runtime, when the problem is localized to a group, critical paths are matched to search space to find the relevant path.
2. To match a path to the search space, iterate the paths in the search space concurrently with the critical path. For any node in the critical path, we iterate the search space until an identical node is found.

### 4.3 Strategy
1. Hierarchy is top-down: First enabling lowest granularity and most general spans, and at each cycle enabling more and more granular spans to narrow down performance problems.

### 4.4 Flat
1. Does not rely on the hierarchy, and instead only uses the happens before relationships to find which trace points to enable.
2. Matches the problem groups to the search space and finds the closet matching critical paths.
3. Enables trace points that divide the most problematic edge equally, based on the budget.


### happen-before: system definition
hierachy: span inside span; caller/callee refers to spans

## Happens-Before Relationship

## Documentation Location
file:///Users/sir/Desktop/projects/target/doc/pythia/search/flat/index.html

## Common Context

## Run Pythia
1. Go to cloudlab.us
2. Start an experiment with "tracing-Pythia".
3. Parameters: The only parameters tested to work are # of compute nodes and disk image. For disk image, use tracing-pythia-PG0//base-with-repos for both node types (compute/controller).
4. Select your cluster (I usually use Utah) and schedule creation/create immediately.
5. Wait for ~1 hours until you get an email saying openstack is ready. Before this, the setup will be unusable.


