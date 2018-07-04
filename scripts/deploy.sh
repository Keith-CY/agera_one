#!/bin/bash
PORT=4000 MIX_ENV=prod elixir --detached -S mix phx.server

