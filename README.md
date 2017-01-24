# cPowerPlan
**cPowerPlan** is a DSC Module and contains the **cPowerPlan** resource. The resource can be used to set the desired power plan used by Windows.

# Installation
To install **cPowerPlan** module:

* If you are using WMF4 / PowerShell Version 4: Unzip the content under the C:\Program Files\WindowsPowerShell\Modules folder

* If you are using WMF5: From an elevated PowerShell session run "Install-Module cPowerPlan"


To confirm installation:
* Run Get-DSCResource to see that the resources listed above are among the DSC Resources displayed

# Resources

cPowerPlan resource has following properties
* **IsSingleInstance**: Specifies that the resource can ony be used a singe time in a configuration. The value must be always { Yes }. Required.
* **PowerPlan**: Specifies the name of the power plan to set. Possible values are: {Balanced | High performance | Power saver}. Required.

# Versions
1.0.1.0

* Rewritten for compatibility with core and nano server

1.0.0.0

* Initial release with the following resources
  * cPowerPlan
