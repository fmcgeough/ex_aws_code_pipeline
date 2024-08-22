defmodule ExAws.CodePipeline.Utils do
  @moduledoc """
  Helper utility functions
  """

  # There are keys that are encountered that have special rules for capitalizing
  # for subkeys found in them.
  @camelize_subkeys %{}
  @camelize_rules %{
    subkeys: @camelize_subkeys,
    default: :lower,
    keys: %{s3_bucket: :upper, s3_object_key: :upper}
  }

  @typedoc """
  Approach to camelization

  - upper - all words are upper-cased
  - lower - the first word is lower cased and the remaining words are upper-cased

  ## Examples

  <!-- tabs-open -->

  ### :upper

  ```
  iex> camelize_rules = %{default: :upper}
  iex> ExAws.CodePipeline.Utils.camelize(:test_things, camelize_rules)
  "TestThings"

  iex> camelize_rules = %{default: :upper}
  iex> ExAws.CodePipeline.Utils.camelize(:abc, camelize_rules)
  "Abc"

  iex> camelize_rules = %{default: :upper}
  iex> ExAws.CodePipeline.Utils.camelize("test-a-string", camelize_rules)
  "TestAString"
  ```

  ### :lower

  ```
  iex> camelize_rules = %{default: :lower}
  iex> ExAws.CodePipeline.Utils.camelize(:test_things, camelize_rules)
  "testThings"

  iex> camelize_rules = %{default: :lower}
  iex> ExAws.CodePipeline.Utils.camelize(:abc, camelize_rules)
  "abc"

  iex> camelize_rules = %{default: :lower}
  iex> ExAws.CodePipeline.Utils.camelize("test-a-string", camelize_rules)
  "testAString"
  ```
  <!-- tabs-close -->
  """
  @type camelization() :: :upper | :lower

  @typedoc """
  The camelize, camelize_list, and camelize_map take an argument that is
  a data structure providing rules for capitalization.

  - subkeys - this provides a map that indicates how keys found under this
    particular key should be camelized
  - keys - this provides a map that indicate how particular keys should be
    camelized
  - default - indicates whether `:upper` or `:lower` is used by default
  """
  @type camelize_rules() :: %{
          optional(:subkeys) => %{optional(atom()) => camelization()},
          optional(:keys) => %{optional(atom()) => camelization()},
          required(:default) => camelization()
        }

  @doc """
  Return the default camelize rules

  A caller can override this by creating a `t:camelize_rules/0` and passing
  it into functions instead of the default.
  """
  @spec camelize_rules() :: camelize_rules()
  def camelize_rules, do: @camelize_rules

  @spec camelize(atom() | binary(), camelize_rules()) :: binary()
  @doc """
  Camelize an atom or string value

  This works as expected if the val uses an underscore or
  hyphen to separate words. This only works for atoms and
  strings. Passing another value type (integer, list, map)
  will raise exception.

  The regex used to split a String into words is: `~r/(?:^|[-_])|(?=[A-Z])/`

  ## Example

      iex> ExAws.CodePipeline.Utils.camelize(:test_val)
      "testVal"

      iex> ExAws.CodePipeline.Utils.camelize(:"test_val")
      "testVal"

      iex> ExAws.CodePipeline.Utils.camelize(:"abc-def-a123")
      "abcDefA123"

      iex> ExAws.CodePipeline.Utils.camelize(:A_test_of_initial_cap)
      "aTestOfInitialCap"
  """
  def camelize(val, camelize_rules \\ @camelize_rules) do
    if is_atom(val) do
      camelization = camelization_for_val(val, camelize_rules)
      val |> to_string() |> string_camelize(%{camelize_rules | default: camelization})
    else
      val
    end
  end

  def string_camelize(val, camelize_rules) when is_binary(val) do
    ~r/(?:^|[-_])|(?=[A-Z])/
    |> Regex.split(val, trim: true)
    |> camelize_split_string(camelize_rules.default)
    |> Enum.join()
  end

  @doc """
  Camelize keys, including traversing values that are also Maps.

  The caller can pass in an argument to indicate whether the first letter of a key for the map are
  downcased or capitalized.

  Keys should be atoms and follow the rules listed for the `camelize/2` function.

  ## Example

      iex> val = %{abc_def: 123, another_val: "val2"}
      iex> ExAws.CodePipeline.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => "val2"}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodePipeline.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => %{"embedValue" => "val2"}}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodePipeline.Utils.camelize_map(val, %{subkeys: %{}, keys: %{}, default: :upper})
      %{"AbcDef" => 123, "AnotherVal" => %{"EmbedValue" => "val2"}}
  """
  def camelize_map(val, camelize_rules \\ @camelize_rules)

  def camelize_map(a_map, camelize_rules) when is_map(a_map) do
    for {key, val} <- a_map, into: %{} do
      camelized_key = camelize(key, camelize_rules)
      subkey_capitalization = Map.get(camelize_rules.subkeys, key, camelize_rules.keys)
      {camelized_key, camelize_map(val, %{camelize_rules | keys: subkey_capitalization})}
    end
  end

  def camelize_map(a_list, camelize_rules) when is_list(a_list) do
    Enum.map(a_list, &camelize_map(&1, camelize_rules))
  end

  def camelize_map(val, _camelize_rules), do: val

  @doc """
  If val is a Keyword then convert to a Map, else return val.

  This function works recursively. If you have a Keyword list where
  the value for the key is a keyword then the val is converted to
  a Map as well.

  ## Examples

      iex> ExAws.CodePipeline.Utils.keyword_to_map([{:a, 7}, {:b, "abc"}])
      %{a: 7, b: "abc"}

      iex> ExAws.CodePipeline.Utils.keyword_to_map(%{a: 7, b: %{c: "abc"}})
      %{a: 7, b: %{c: "abc"}}

      iex> ExAws.CodePipeline.Utils.keyword_to_map([1, 2, 3])
      [1, 2, 3]

      iex> ExAws.CodePipeline.Utils.keyword_to_map[test: [inner: "abc"]]
      %{test: %{inner: "abc"}}
  """
  def keyword_to_map(val) do
    cond do
      val == [] ->
        []

      Keyword.keyword?(val) ->
        Enum.map(val, fn {k, v} ->
          {k, keyword_to_map(v)}
        end)
        |> Map.new()

      is_list(val) ->
        Enum.map(val, &keyword_to_map/1)

      is_map(val) ->
        Enum.map(val, fn {k, v} -> {k, keyword_to_map(v)} end) |> Map.new()

      true ->
        val
    end
  end

  defp camelization_for_val(val, %{keys: keys, default: default}) do
    Map.get(keys, val, default)
  end

  defp camelization_for_val(_val, %{default: default}), do: default

  # Camelize a word that has been split into parts
  #
  # The caller can pass in an argument to indicate whether the first letter of the first element in
  # the list is downcased or capitalized. The remainder elements are always capitalized.
  #
  # ## Examples
  #
  #     iex> ExAws.CodePipeline.Utils.camelize_split_string([], :lower)
  #     []
  #
  #     iex> ExAws.CodePipeline.Utils.camelize_split_string(["a", "cat"], :lower)
  #     ["a", "Cat"]
  #
  #     iex> ExAws.CodePipeline.Utils.camelize_split_string(["a", "cat"], :upper)
  #     ["A", "Cat"]
  defp camelize_split_string([], _), do: []

  defp camelize_split_string([h | t], :lower) do
    [String.downcase(h)] ++ camelize_split_string(t, :upper)
  end

  defp camelize_split_string([h | t], :upper) do
    [String.capitalize(h)] ++ camelize_split_string(t, :upper)
  end
end
