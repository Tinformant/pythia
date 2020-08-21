# Pythia Hybrid Search
## Milestones
### 08/20
- [ ] Presentation
     - [X] The high-level problem search strategies intend to solve
     - [ ] How the hierarchical search strategy and flat search strategy work.
          * Pictures or animations
     - [X] What the problem is with the hierarchical search strategy.  
          * Come up with an example that illustrates this problem?
     - [ ] Your solution and modifications / along with a demo.
     - [ ] Create a toy search space (have to manually add spans)
### 08/13
- [X] Modifying SearchStrategy so that HybridSearch can take in both budget and threshold
- [X] Figure out about if hierarchical search is level-order or not
    * NO
- [X] Fixing Hybrid Search to level-order
- [ ] Use testing framework to generate testing
- [ ] Testing with real data

### 08/06
- [X] Rewriting split by n
- [X] How is flat search adhering to the budget and would it be possible to replicate that in hierarchical search?  Would what the algorithm be and what are the drawbacks?  
   - Budget is a input parameter in the interface so it is used in both cases. In flat search, it is used for dividing an edge into budget number of subedges. In hierarchical search, it is used in randomly selecting children spans.
- [X] Technically, traces are comprised of “spans” (pairs of trace points labeled with _ENTRY and _EXIT) and annotations (just a single trace point denoting an important event). For the former, do the search strategies always turn on trace points in pairs?  
    * get_context() returns all nodes between the starting node of the group and the node of interest
    * Returns every "Entry" trace point
    * Only returns "Annotation" trace point if it is also the node of interest
    * Does not return "Exit" trace point
### Done
- [x] Find where it is randomly searching in hierarchical search
- [x] Understand why hierarchical search needs the common context
- [x] Implement hybrid search
- [x] Hybrid search threshold and budget?

## Quotes by Emre
What I envisioned the new search strategy to be was: to follow what the hierarchical strategy is doing except when there are many candidate trace points in one level of the hierarchy, where we could split them like the flat search. According to what I saw, hierarchical search spends the most time on finding which tracepoint in a level is problematic and doesn't use the happens-before relationships like the flat search which would speed up this part of the search.

## On Hybrid Search
"The search strategies are provided a problematic group, and the number of trace points to enable."
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

### Pseudo Code
```
fn hierarchical_search (problem_group, problem_edge, budget) -> Vec<TracepointID> {
    // Get source and target nodes of the problematic edge
    let (source, target) = problem_group.g.edge_endpoints(edge);
    // Get calling context of source and target
    let source_context = get_context(problem_group, source);
    let target_context = get_context(problem_group, target);
    
    // Find common context (common calling context)
    let mut common_context = Vec::new();
    let mut idx = 0;
    loop {
        if idx >= source_context.len() || idx >= target_context.len() {
           break;
        } else if source_context[idx] == target_context[idx] {
           common_context.push(source_context[idx]);
           idx += 1;
        } else {
           break;
        }
    }
   println!("Common context for the search: {:?}", common_context);
   // Match the problem group to the search space and finds the closest matching critical paths
   let matches = self.manifest.find_matches(group);

   // matches are the closest matching critical paths to the group
   let mut result = self.search_context(&matches, common_context);

   result = result
       .into_iter()
       .filter(|&x| !self.controller.is_enabled(&(x, Some(group.request_type))))
       .collect();
   /* Chooses budget amount elements from the slice at random
    * without repeating any, and returns them in random order.
    */
   let mut rng = &mut rand::thread_rng();
   result = result.choose_multiple(&mut rng, budget).cloned().collect();
   result
}
```
```rust
fn search(&self, group: &Group, edge: EdgeIndex, budget: usize) -> Vec<TracepointID> {
   let mut rng = &mut rand::thread_rng();
   // Get source and target nodes of the problematic edge
   let (source, target) = group.g.edge_endpoints(edge).unwrap();

   let source_context = HierarchicalSearch::get_context(group, source);
   let target_context = HierarchicalSearch::get_context(group, target);

   // Find common context (common calling context)
   let mut common_context = Vec::new();
   let mut idx = 0;
   loop {
       if idx >= source_context.len() || idx >= target_context.len() {
           break;
       } else if source_context[idx] == target_context[idx] {
           common_context.push(source_context[idx]);
           idx += 1;
       } else {
           break;
       }
   }
   println!("Common context for the search: {:?}", common_context);
   // Match the problem group to the search space and finds the closest matching critical paths
   let matches = self.manifest.find_matches(group);

   // matches are the closest matching critical paths to the group
   let mut result = self.search_context(&matches, common_context);

   /* into_iter() creates a consuming iterator, that is, one that moves each value out of
   *  the vector (from start to end). The vector cannot be used after calling this
   *  filter() filters the elements of iter with predicate.
   *  collect() turns an iterator into a collection
   */
   result = result
       .into_iter()
       .filter(|&x| !self.controller.is_enabled(&(x, Some(group.request_type))))
       .collect();
   /* choose_multiple: produces an iterator that chooses amount elements from the slice at random
    * without repeating any, and returns them in random order.
    */
   result = result.choose_multiple(&mut rng, budget).cloned().collect();
   result
}
```
### Flat Search Pseudo Code
```rust
fn search(&self, group: &Group, edge: EdgeIndex, budget: usize) -> Vec<TracepointID> {

}
```

**Original**
```rust
fn search(&self, group: &Group, edge: EdgeIndex, budget: usize) -> Vec<TracepointID> {
   let matches = self.manifest.find_matches(group);
   let mut result = HashSet::new();
   for m in matches {
       let now = Instant::now();
       // Each is cost 1
       let remaining_budget = budget - result.len();
       // take() makes the iterator finite
       result.extend(
           self.split_group_by_n(m, group, edge, remaining_budget)
               .iter()
               .take(remaining_budget),
       );
       eprintln!("Finding middle took {}", now.elapsed().as_micros(),);
       result = result
           .into_iter()
           .filter(|&x| !self.controller.is_enabled(&(x, Some(group.request_type))))
           .collect();
   }
   result.drain().collect()
}
```

### happen-before: system definition
hierachy: span inside span; caller/callee refers to spans

## Happens-Before Relationship

## Documentation Location
file:///Users/sir/Desktop/projects/target/doc/pythia/search/flat/index.html

## Common Context

## Running Pythia on Cloudlab
### Setup Pythia on Cloudlab
1. At cloudlab.us, start an experiment with "tracing-Pythia".
2. For experiment setup, the only parameters tested to work are # of compute nodes and disk image. For disk image, use 
```tracing-pythia-PG0//base-with-repos``` for both node types (compute/controller). Leave all other fields as default values.
3. Select cluster (Emre usually uses Utah) and schedule creation/create immediately.
    * Sometimes, setup may randomly fail. Trying a couple more times will usually work.
4. Wait for 2 emails until setup is complete.
    * Expect first email saying "OpenStack Instance Setting Up" right after cluster creation
    * Second email will arive about 1.5 hour later saying "OpenStack Instance Finished Setting Up"
### Update Configuration Files
1. Configuration file is ```/etc/pythia/controller.toml```
    * Change ```pythia_clients``` according to the actual number of nodes
    * Change ```uber_trace_dir``` to where the uber trace is
### Creating Search Space
**Manifest is synonym for search space.**
1. May have to change to Emre's user to load the correct bashrc before running offline profiling, so run ```sudo su emreates``` 
1. Running some workload with all the instrumentation enabled: for OpenStack, this workload is in the script ```/local/tracing-pythia/workloads/offline_profiling.sh``` May need to manually pull the latest version of the code to get the script.
2. This script generates a list of trace_ids in the file ~/offline_profiling.sh.
5. Change ```num_iters``` in offline_profiling.sh
3. Use cargo run manifest <path/to/trace/ids> to generate the manifest. It is stored in /opt/stack/manifest.json.
1. At ```/local/reconstruction/```, run command: ```cargo run manifest /users/emreates/offline_traces.txt```
4. Follow the instructions here: ```file:///Users/sir/Desktop/projects/target/doc/pythia/index.html```
### Running Pythia
1. At ```~/reconstruction``` (~ tilda just means home directory), run command: ```RUST_BACKTRACE=1 cargo run --bin pythia_controller ~/pythia.log 2>&1 | tee ~/pythia_verbose.log```
    * This will start pythia; if something goes, we will get back trace
2. traces: /home/ates/tracing/traces


