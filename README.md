# Infigonia

> Please read each module, it has @moduledoc for explanation.
> See DynamicSupervisor for better understanding of each worker start up.
> I started working on this 2 days ago, and Today is my last day to work on this, so I have skipped on writing unit tests, If I would have more time then I would have written a few for GenServers.
> Cheers.

## Set up

- Install Elixir 1.12.x using asdf.
- mix deps.get && mix deps.compile
- mix release
- _build/dev/rel/infigonia/bin/infigonia start or daemon or daemon_iex


## Update 3.0
  - So I have added a new structer, using Oban and Libcluster.
  - Every Job is now being run and added through Cron Runner of Oban.
    * Each module has a main perfomer and then its adding a single unique worker in case of Source URL, URL is unique and in case of parser the path is unique.
    * Oban has this builtin feature to spread queues on multiple nodes.
    * It will also make the queues distributed as well as no job will be duplicated as well.
  - I have added Libclsuter as well which will connect the nodes with each other. so Oban will also know which node is joing which job and it wont duplicated the jobs.
    * We are using `Cluster.Strategy.Gossip` strategy for the moment to run the nodes locally.
    * `iex --sname a -S mix`, `iex --sname b -S mix`, `iex --sname c -S mix` and so on.
    * Gossipe strategy will discover the nodes and connect.
    * Libcluster has multiple strategies, for making connection with nodes as well as written hosts and discovery as well.
  - Sources table has been added and removed from State of GenServer as we have removed GenServer now, totally and DynamicSupervisor has gone as well.
  - `Infigonia.Sources.Source.insert/1` has been added to update the source, the worker will get sources after 6 hours and start adding jobs, and it will be spreaded out to multiple nodes as well. See Application.ex file for details and Oban linked hex docs.