- import renameVM workflow in vRO

- add this custom propertty:
Extensibility.Lifecycle.Properties.VMPSMasterWorkflow32.BuildingMachine = *

- add with EBS:
Machine provisioning
	All of the following 	-> Data | Lyfe cycle state name equaks VMPSMasterWorkflow32.BuildingMachine && 
				-> Data | State phase equals PRE &&
				-> Data | Machine Type equals Virtual Machine
	add the corresponding workflow
