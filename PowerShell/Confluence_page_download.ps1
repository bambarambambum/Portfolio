filter Convert-Encoding {
  $UTF8 = [System.Text.Encoding]::GetEncoding("UTF-8")
  $28591 = [System.Text.Encoding]::GetEncoding(28591)
  $UTF8.GetString($28591.GetBytes($_))
}

Write-Host "Введите имя пользователя"
$login = Read-Host
Write-Host "Введите пароль"
$password = Read-Host -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($login):$($value)"))

$response = Invoke-RestMethod -Uri "https://DOMAIN/rest/api/space/SPACE_NAME/content/page?limit=99999" `
    -Headers @{ Authorization = "Basic "+ $cred } -Method Get

# Очистка каталога перед удалением 
Remove-item "\\random_path\pages" -Recurse

# Создание каталога
New-Item -ItemType directory "\\random_path\pages"
foreach ($record in $response.results) {

    $title = $record.title | Convert-Encoding
    New-Item -Path "\\random_path\pages" -Name "$title.html" -ItemType "file" -Force
    $page = Invoke-RestMethod -Uri "https://DOMAIN$($record._links.webui)" `
    -Headers @{ Authorization = "Basic "+ $cred } -Method Get
    Add-content "\\random_path\pages\$title.html" -value $page -Encoding UTF8
}

