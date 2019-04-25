# the following try/except block will make the custom check compatible with any Agent version	
try:
    # first, try to import the base class from old versions of the Agent...
    from checks import AgentCheck
except ImportError:
    # ...if the above failed, the check is running in Agent version 6 or later
    from datadog_checks.checks import AgentCheck

from datadog_checks.utils.subprocess_output import get_subprocess_output

# content of the special variable __version__ will be shown in the Agent status page
__version__ = "1.0.0"


class Custom_WinServMonitorCheck(AgentCheck):
	def check(self, instance):
		output, err, retcode = get_subprocess_output(["powershell.exe", "C:\ProgramData\Datadog\checks.d\custom_WinServMonitor.ps1"], self.log, raise_on_empty_output=True)
		if output.startswith('OK'):
			self.gauge('custom_WinServMonitor.autoNotStarted', 0)
		else:
			outList=[]
			for service in output.split(';'):
				service = service.strip()
				outList.append('service:'+service)
			self.gauge('custom_WinServMonitor.autoNotStarted', 1, outList)
			
