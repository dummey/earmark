defmodule Regressions.I110ListWith2Spaces do
  use ExUnit.Case

  @moduletag :wip

  @vanilla_list """
  * a
      * b
  * c
  """

  @two_space_list """
  * a
    * b
  *c
  """

  test "two space lists" do
    assert Earmark.as_html!(@vanilla_list) == Earmark.as_html!(@two_space_list)
  end

end