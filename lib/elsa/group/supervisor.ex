defmodule Elsa.Group.Supervisor do
  use Supervisor

  def start_link(init_arg \\ []) do
    group = Keyword.fetch!(init_arg, :group)
    supervisor_name = :"elsa_supervisor_#{group}"
    Supervisor.start_link(__MODULE__, init_arg, name: supervisor_name)
  end

  @impl Supervisor
  def init(init_arg) do
    name = Keyword.fetch!(init_arg, :name)
    registry_name = registry(name)

    children = [
      {Registry, [keys: :unique, name: registry_name]},
      {DynamicSupervisor, [strategy: :one_for_one, name: {:via, Registry, {registry_name, :worker_supervisor}}]},
      {Elsa.Group.Manager, manager_args(init_arg)}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def registry(name) do
    :"elsa_registry_#{name}"
  end

  defp manager_args(args) do
    args
    |> Keyword.put(:supervisor_pid, self())
  end
end