defmodule Exchange.Adapters.Helpers do
  @moduledoc ~S"""
  Module used by every adapter to validate configurations and dependencies.
  """
  require Logger

  @doc """
  Evaluates if the required configuration is defined


  ## Parameters
    - required_config: list of atoms containing the required configuration
    - config: current configuration

  """

  @spec validate_config([atom], Keyword.t(), atom) :: :ok | no_return
  def validate_config(required_config, config, module) do
    missing_keys =
      Enum.reduce(required_config, [], fn key, missing_keys ->
        if config[key] in [nil, ""],
          do: [key | missing_keys],
          else: missing_keys
      end)

    raise_on_missing_config(missing_keys, config, module)
  end

  defp raise_on_missing_config([], _config, _module), do: :ok

  defp raise_on_missing_config(key, config, module) do
    Logger.error(
      "When using #{inspect(module)} are expected #{inspect(key)} to be set, got: #{inspect(config)}"
    )

    raise ArgumentError, "missing configuration"
  end

  @doc """
  Evaluates if the required dependencies are loaded

  ## Parameters
    - required_deps: list containing the required dependencies
  """
  @spec validate_dependency([module | {atom, module}], module) :: :ok | no_return
  def validate_dependency(required_deps, module) do
    missing_dependencies =
      Enum.reduce(required_deps, [], fn dep, acc_missing_dependencies ->
        dep_loaded =
          case dep do
            {_lib, module} ->
              Code.ensure_loaded?(module)

            module ->
              Code.ensure_loaded?(module)
          end

        if dep_loaded do
          acc_missing_dependencies
        else
          [dep | acc_missing_dependencies]
        end
      end)

    raise_on_missing_dependency(missing_dependencies, module)
  end

  defp raise_on_missing_dependency([], _), do: :ok

  defp raise_on_missing_dependency(keys, module) do
    Logger.error(
      "Expected module(s) #{inspect(keys)} to be loaded when using #{module}. Add them to the dependencies and run mix deps.get."
    )

    raise ArgumentError, "missing dependecies."
  end
end
