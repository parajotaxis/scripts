param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [PSCredential]$Credential
)

try {
    # Obtém o objeto WMI do perfil de usuário
    $UserProfile = Get-WmiObject -Class Win32_UserProfile -ComputerName $ComputerName -Credential $Credential | Where-Object {$_.LocalPath -like "*$Username*"}

    if ($UserProfile) {
        # Remove o perfil
        $UserProfile | Remove-WmiObject -Force

        Write-Host "Perfil do usuário '$Username' removido com sucesso do computador '$ComputerName'."
    } else {
        Write-Host "Perfil do usuário '$Username' não encontrado no computador '$ComputerName'."
    }
} catch {
    Write-Error "Ocorreu um erro ao remover o perfil: $_"
}