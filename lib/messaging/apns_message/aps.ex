defmodule FirebaseAdminEx.Messaging.APNSMessage.Aps do
	@moduledoc """
	This module is responsible for representing the
	attributes of APNSMessage.Aps.
	"""
	
	alias FirebaseAdminEx.Messaging.APNSMessage.Alert
	
	@keys [
		"thread-id": "",
		alert: %Alert{},
		badge: 0,
		sound: "default",
		category: "",
		"content-available": 1
	]
	
	@type t :: %__MODULE__{
				   "thread-id": String.t(),
				   alert: struct(),
				   badge: integer(),
				   sound: String.t(),
				   category: String.t(),
				   "content-available": integer()
			   }
	
	@derive Jason.Encoder
	defstruct @keys
	
	# Public API
	
	def new(attributes \\ %{}) do
		%__MODULE__{
			"thread-id": Map.get(attributes, :"thread-id", ""),
			alert: Alert.new(Map.get(attributes, :alert)),
			badge: Map.get(attributes, :badge, 0),
			sound: Map.get(attributes, :sound, "default"),
			category: Map.get(attributes, :category, ""),
			"content-available": Map.get(attributes, :"content-available", 1)
		}
	end
	
	def validate(%__MODULE__{alert: nil} = message), do: {:ok, message}
	
	def validate(%__MODULE__{alert: alert} = message_config) do
		case Alert.validate(alert) do
			{:ok, _} ->
				{:ok, message_config}
			
			{:error, error_message} ->
				{:error, error_message}
		end
	end
	
	def validate(_), do: {:error, "[APNSMessage.Aps] Invalid payload"}
end
