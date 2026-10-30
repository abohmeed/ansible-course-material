work

### Create the role

```
ansible-galaxy init roles/aspnet
```

### Define the variables

```
# defaults/main.yml
app_name: "/sample"
app_path: "C:"
```

### Define the application template

Create a new directory under files:

```
mkdir roles/aspnet/files/SampleAspNetFrameworkApp
```

Add the following files:

```
// roles/aspnet/files/SampleAspNetFrameworkApp/Default.aspx
<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ASP.NET Framework</title>
</head>
<body>
    <h1>Welcome to ASP.NET Framework!</h1>
    <p>
        <asp:Literal ID="Message" runat="server"></asp:Literal>
    </p>
</body>
</html>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        // Dynamically generate a welcome message based on the time of day
        var hour = DateTime.Now.Hour;
        string message;

        if (hour < 12)
            message = "Good Morning!";
        else if (hour < 18)
            message = "Good Afternoon!";
        else
            message = "Good Evening!";

        // Assign the message to the Literal control
        Message.Text = message + " The current time is " + DateTime.Now.ToString("hh:mm tt");
    }
</script>
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.web>
    <compilation debug="true" targetFramework="4.7.2" />
    <httpRuntime targetFramework="4.7.2" />
  </system.web>
</configuration>
```

### Define the tasks file

```
---
# tasks file for roles/aspnet
- name: Install IIS
  win_feature:
    name:
      - Web-Server               # IIS Web Server
      - Web-Mgmt-Tools           # Management Tools
      - Web-Net-Ext              # .NET Framework Extensions
      - Web-Asp-Net45            # ASP.NET 4.5 (optional for .NET Framework apps)
      - Web-Net-Ext45            # .NET Framework 4.5 Extensions

- name: Deploy ASP.NET Framework application
  win_copy:
    src: SampleAspNetFrameworkApp
    dest: "{{ app_path }}"

- name: Add application to Default Web Site
  community.windows.win_iis_webapplication:
    name: "{{ app_name }}"
    site: "Default Web Site"
    physical_path: "{{ app_path }}\\SampleAspNetFrameworkApp"
    state: present
  notify: Restart IIS
```

### Define any handlers

```
---
# handlers file for roles/lammp_windows_setup
- name: Restart IIS
  ansible.windows.win_service:
    name: "w3svc"
    state: "restarted"
```

### Modify the playbook to include the new role

```
# playbook.yaml
- name: Manage Windows user
  hosts: winhost
  roles:
    - windows_user_management
    - aspnet
```

### Run the playbook

```
ansible-playbook  -i inventory/hosts playbook.yaml
```

### Verify the results

Make sure that the Security Group allows HTTP connections.

Browse to the root of the web application by typing the machine's hostname. It should bring the IIS Welcome page.

Browse to /sample and you should see the custom welcome page with the greeting tailored to the time of the day.

