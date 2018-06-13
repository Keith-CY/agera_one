defmodule AgeraOne.Chain.Periodically do
  use GenServer
  alias AgeraOne.Chain

  # @number "0x0"

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    schedule_work()
    Chain.sync_block()

    # get latest header in db
    # cache next block
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 100_00)
  end
end
