add this custum propertty:
Extensibility.Lifecycle.Properties.VMPSMasterWorkflow32.BuildingMachine = *

Add with EDS:
Machine provisioning
	All of the following 	-> Data | Lyfe cycle state name equaks VMPSMasterWorkflow32.BuildingMachine && 
				-> Data | State phase equals PRE &&
				-> Data | Machine Type equals Virtual Machine
	add the corresponding zorkflow
