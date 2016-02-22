Instructions for updating the web application:

Inside the app code, you will need to ensure that the connection string element of web.config has been updated for your instance

By default, if will look for a named instance called 'SQL2016CTP32' on localhost.  You can update to whatever is needed.
  <connectionStrings>
    <add name="RandomEntities" connectionString="metadata=res://*/Models.EmployeesModel.csdl|res://*/Models.EmployeesModel.ssdl|res://*/Models.EmployeesModel.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=localhost\sql2016ctp32;initial catalog=Random;integrated security=True;MultipleActiveResultSets=True;App=EntityFramework;Column Encryption Setting=Enabled&quot;" providerName="System.Data.EntityClient"/>
  </connectionStrings>

The option "Column Encryption Setting=Enabled" is necessary for the AlwaysEncrypted functionality to work.