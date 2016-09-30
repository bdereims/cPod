- Import renameVM workflow in vRO

- Add this Customx.Property:
Extensibility.Lifecycle.Properties.VMPSMasterWorkflow32.BuildingMachine = *

- You must register the vRA IaaS Host of the "Default" vRA Host
Library -> vRealize Automation -> Configuration -> Add the IaaS Host of a vRA Host

- Add within EBS:
Machine provisioning
	All of the following 	-> Data | Lyfe cycle state name equaks VMPSMasterWorkflow32.BuildingMachine && 
				-> Data | State phase equals PRE &&
				-> Data | Machine Type equals Virtual Machine
	Add the corresponding workflow
