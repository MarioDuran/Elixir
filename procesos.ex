defmodule ClienteService do
  def fetch(cliente_id) do
    Process.sleep(800)
    %{cliente_id: cliente_id, nombre: "Cliente #{cliente_id}"}
  end
end

defmodule EnvioService do
  def cotizar(producto_id) do
    Process.sleep(1200)
    %{producto_id: producto_id, costo_envio: producto_id |> rem(5) |> Kernel.+(1) |> Kernel.*(100)}
  end
end

defmodule InventarioService do
  def stock(producto_id) do
    Process.sleep(1000)
    %{producto_id: producto_id, disponible: rem(producto_id, 2) == 0}
  end
end

defmodule PedidoEnricher do
  def enriquecer_secuencial(pedido) do
    task_cliente = Task.async(fn -> ClienteService.fetch(pedido.cliente_id) end)
    task_envio = Task.async(fn -> EnvioService.cotizar(pedido.producto_id) end)
    task_inventario = Task.async(fn -> InventarioService.stock(pedido.producto_id) end)

    cliente = Task.await(task_cliente)
    envio = Task.await(task_envio)
    inventario = Task.await(task_inventario)

    %{
      id: pedido.id,
      cliente: cliente,
      envio: envio,
      inventario: inventario
    }
  end
end

pedidos = [
  %{id: 1, cliente_id: 101, producto_id: 501},
  %{id: 2, cliente_id: 102, producto_id: 502},
  %{id: 3, cliente_id: 103, producto_id: 503}
]

#resultado = Enum.map(pedidos, fn pedido -> PedidoEnricher.enriquecer_secuencial(pedido) end)
resultado = Enum.map(pedidos, &PedidoEnricher.enriquecer_secuencial/1)
IO.inspect(resultado)
