# ================================
# CONFIG
# ================================
$printerPath = "\\smlsawsengvp03\IMPMILLS_COLOR"
$Status = "Sem problemas"
$ExitCode = 0

# ================================
# VERIFICAR INTUNE
# ================================
$intuneOK = $false

try {
    $enroll = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\*" -ErrorAction SilentlyContinue
    if ($enroll) {
        $intuneOK = $true
    }
}
catch {}

# ================================
# EXECUÃ‡ÃƒO
# ================================
try {

    # Garante spooler
    Start-Service spooler -ErrorAction SilentlyContinue

    # Verifica se jÃ¡ existe
    $printerExists = Get-Printer | Where-Object {$_.Name -eq $printerPath}

    if (-not $printerExists) {
        Write-Output "Adicionando impressora..."
        Add-Printer -ConnectionName $printerPath -ErrorAction Stop
    }

    # Define padrÃ£o
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($printerPath)

}
catch {
    $Status = "Falha"
    $ExitCode = 2
}

# ================================
# VALIDAÃ‡ÃƒO FINAL
# ================================
$finalCheck = Get-Printer | Where-Object {$_.Name -eq $printerPath}

if (-not $finalCheck) {
    $Status = "Com problemas"
    $ExitCode = 1
}

# ================================
# STATUS INTUNE
# ================================
if (-not $intuneOK) {
    $Status = "NÃ£o aplicÃ¡vel"
    $ExitCode = 0
}

# ================================
# LOG
# ================================
$logPath = "C:\ProgramData\IntuneLogs"
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

"$((Get-Date)) - $Status - Impressora: $printerPath" | Out-File "$logPath\Printer.log" -Append

# ================================
# OUTPUT FINAL
# ================================
Write-Output "Status: $Status"

exit $ExitCode