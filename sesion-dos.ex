defmodule AreaCalculator do
  def areaCuadrado(b, a), do: b * a


  def areaCirculo(r) do
    3.1416 * r * r
  end

  def esNumeroPar?(n) do
    rem(n, 2) == 0
  end
end
