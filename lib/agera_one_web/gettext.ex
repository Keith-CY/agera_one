defmodule AgeraOneWeb.Gettext do
  alias AgeraOne.Chain

  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import AgeraOneWeb.Gettext

      # Simple translation
      gettext "Here is the string to translate"

      # Plural translation
      ngettext "Here is the string to translate",
               "Here are the strings to translate",
               3

      # Domain-based translation
      dgettext "errors", "Here is the error message to translate"

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :agera_one

  def hex_to_int(hex) do
    hex |> Chain.hex_to_int()
  end

  def int_to_hex(int) do
    int |> Chain.int_to_hex()
  end
end
