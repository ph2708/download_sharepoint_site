param
(
    [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0, 
        HelpMessage="Por favor, forneça a URL no seguinte formato: https://maquigeral.sharepoint.com/sites/VENDASMAQUIGERAL")
    ]
    $SiteUrl,

    [Parameter(
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1,
        HelpMessage="Por favor, forneça o caminho onde os arquivos baixados devem ser armazenados.")
    ]
    $DownloadPath,

    [switch][Parameter(
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
        Position=2,
        HelpMessage="Use o parâmetro -Force para substituir arquivos existentes.")
    ]
    $Force = $true
)

# Conectar ao SharePoint Online
Connect-PnPOnline -Url $SiteUrl -Interactive

# Criar pasta se não existir
If (!(Test-Path $DownloadPath))
{
    New-Item -ItemType Directory $DownloadPath
}

# Obter o nome da lista
$ListName = Get-PnPList -Identity "Documentos Compartilhados" | Select-Object Title -ExpandProperty Title

# Baixar arquivos
If ($Force)
{
    Get-PnPListItem -List $ListName | 
    Select-Object Id,@{N="FileName";E={$_.FieldValues.FileLeafRef}}, @{N="Link";E={$_.FieldValues.FileRef}} |
        ForEach-Object { 
            Get-PnPFile -Url $_.Link -Filename $_.FileName  -Path $DownloadPath -AsFile -Force -WarningAction Stop
            Write-Host "Baixado $($_.FileName) para $DownloadPath" -ForegroundColor Green 
        }
}
Else
{
    Get-PnPListItem -List $ListName | 
    Select-Object Id,@{N="FileName";E={$_.FieldValues.FileLeafRef}}, @{N="Link";E={$_.FieldValues.FileRef}} |
        ForEach-Object { 
            Get-PnPFile -Url $_.Link -Filename $_.FileName  -Path $DownloadPath -AsFile -WarningAction Stop
            Write-Host "Baixado $($_.FileName) para $DownloadPath" -ForegroundColor Green 
        }
}
