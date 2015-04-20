# neo4j_gem_test

This is a quick performance test of the neo4j gem compared to *acts-as-dag* and *neo4j_ancestry* with *ruby on rails*.

## See also

* https://github.com/fiedl/neo4j_ancestry_vs_acts_as_dag
* Internal: https://trello.com/c/95mYF66W/437-neo4j-ancestry-gem

## Test Definitions

See [spec/performance_spec.rb](spec/performance_spec.rb).

## Results

### Results for acts-as-dag

    $number_of_groups = 100
    $number_of_users  = 10
    
    --------------------------------------------------------------------
    | Description                                        | Duration    |
    --------------------------------------------------------------------
    | creating 100 groups                                | 0.120807 s  |
    | adding 10 users to each of the 100 groups          | 5.208326 s  |
    | moving 100 groups into a parent group              | 4.172726 s  |
    | moving the group structure into an ancestor group  | 4.150828 s  |
    | removing the link to the ancestor group            | 1.662111 s  |
    | destroying the ancestor group                      | 0.000717 s  |
    | finding all descendants                            | 0.028424 s  |
    | finding all descendant users                       | 0.000439 s  |
    --------------------------------------------------------------------

### Results for neo4j_ancestry

    $number_of_groups = 100
    $number_of_users  = 10

    ---------------------------------------------------------------------
    | Description                                        | Duration     |
    ---------------------------------------------------------------------
    | creating 100 groups                                | 0.693674 s   |
    | adding 10 users to each of the 100 groups          | 103.020834s  |
    | moving 100 groups into a parent group              | 10.37782 s   |
    | moving the group structure into an ancestor group  | 0.123451 s   |
    | removing the link to the ancestor group            | 0.148153 s   |
    | destroying the ancestor group                      | 0.071543 s   |
    | finding all descendants                            | 0.616196 s   |
    | finding all descendant users                       | 0.172308 s   |
    ---------------------------------------------------------------------

### Results for neo4j and has_neo_node

    $number_of_groups = 100
    $number_of_users  = 10
    
    ---------------------------------------------------------------------
    | Description                                        | Duration     |
    ---------------------------------------------------------------------
    | creating 100 groups                                | 2.4675473 s  |
    | adding 10 users to each of the 100 groups          | 25.227630 s  |
    | moving 100 groups into a parent group              | 0.1612957 s  |
    | moving the group structure into an ancestor group  | 0.0259047 s  |
    | removing the link to the ancestor group            | 0.0663939 s  |
    | destroying the ancestor group                      | 0.0182183 s  |
    | finding all descendants                            | 0.4834235 s  |
    | finding all descendant users                       | 0.0955578 s  |
    ---------------------------------------------------------------------
