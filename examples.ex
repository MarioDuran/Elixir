# -----------------------------------------------------------------------------
# 1) Task.async + Task.await
# Sirve para correr trabajo concurrente y luego recuperar su resultado.
# -----------------------------------------------------------------------------

defmodule Examples.AsyncAwait do
  def run do
    task =
      Task.async(fn ->
        Process.sleep(100)
        21 * 2
      end)

    result = Task.await(task)
    IO.puts("[async/await] resultado = #{result}")
  end
end

# -----------------------------------------------------------------------------
# 2) Task.start
# Sirve para fire-and-forget: lanzar trabajo sin esperar resultado.
# -----------------------------------------------------------------------------
defmodule Examples.Start do
  def run do
    {:ok, _pid} =
      Task.start(fn ->
        Process.sleep(50)
        IO.puts("[start] tarea sin await")
      end)

    :ok
  end
end

# -----------------------------------------------------------------------------
# 3) Task.start_link
# Similar a start, pero el proceso queda linkeado al proceso actual.
# -----------------------------------------------------------------------------
defmodule Examples.StartLink do
  def run do
    {:ok, _pid} =
      Task.start_link(fn ->
        Process.sleep(50)
        IO.puts("[start_link] tarea linkeada")
      end)

    :ok
  end
end

# -----------------------------------------------------------------------------
# 4) Task.Supervisor.async
# Lanza una task supervisada y espera su resultado.
# -----------------------------------------------------------------------------
defmodule Examples.SupervisorAsync do
  def run do
    {:ok, sup} = Task.Supervisor.start_link()

    task =
      Task.Supervisor.async(sup, fn ->
        Enum.sum([1, 2, 3, 4])
      end)

    result = Task.await(task)
    IO.puts("[Task.Supervisor.async] suma = #{result}")
  end
end

defmodule Examples.AsyncStream do
  def run do
    1..5
    |> Task.async_stream(fn n -> n * n end, max_concurrency: 2, ordered: true)
    |> Enum.each(fn {:ok, value} ->
      IO.puts("[async_stream] valor = #{value}")
    end)
  end
end
