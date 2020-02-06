#!powershell
# This file is part of Ansible

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy.psm1
#Requires -Module Ansible.ModuleUtils.FileUtil.psm1
#Requires -Module Ansible.ModuleUtils.LinkUtil.psm1

#
$ErrorActionPreference = 'Stop'

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$diff_mode = Get-AnsibleParam -obj $params -name "_ansible_diff" -type "bool" -default $false

# these are your module parameters, there are various types which can be
# used to format your parameters. You can also set mandatory parameters
# with -failifempty, set defaults with -default and set choices with
# -validateset.

$clean = Get-AnsibleParam -obj $params -name "clean" -type "bool" -default $true
$current_path = Get-AnsibleParam -obj $params -name "current_path" -type "str" -default "current"
$keep_releases = Get-AnsibleParam -obj $params -name "keep_releases" -type "int" -default 5
$path = Get-AnsibleParam -obj $params -name "path" -type "path" -failifempty $true
$release = Get-AnsibleParam -obj $params -name "release" -type "str" -failifempty $true
$releases_path = Get-AnsibleParam -obj $params -name "releases_path" -type "str" -default "releases"
$shared_path = Get-AnsibleParam -obj $params -name "shared_path" -type "str" -default "shared"
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "absent","present","finalize","clean","query"
$unfinished_filename = Get-AnsibleParam -obj $params -name "unfinished_filename" -default "DEPLOY_UNFINISHED" -type "str"

$params_hashtable = @{
    "clean"=$clean;
    "current_path"=$current_path;
    "keep_releases"=$keep_releases;
    "path"=$path;
    "release"=$release;
    "releases_path"=$releases_path;
    "shared_path"=$shared_path;
    "state"=$state;
    "unfinished_filename"=$unfinished_filename;
}

$result = @{
    ansible_facts = @{ }
    changed = $false
}

if ($diff_mode) {
    $result.diff = @{}
}

Function Gather-Facts() {
    param(
        [hashtable] $deploy_info
    )

    $diff = ""
    $current_path = $deploy_info.path+"\"+$deploy_info.current_path
    $releases_path = $deploy_info.path+"\"+$deploy_info.releases_path

    if ($deploy_info.shared_path){
        $shared_path = $deploy_info.path+"\"+$deploy_info.shared_path+"\source"
    } else {
        $shared_path = $Null
    }

    #TODO: previous_release, previous_release_path = self._get_last_release(current_path)

    if (($deploy_info.release -eq $Null) -And ($deploy_info.state == 'query' -Or $deploy_info.state == 'present')){
            $deploy_info.release = Get-Date -UFormat "%Y%m%d%H%M%S"
    }

    if ($deploy_info.release) {
        $new_release_path = $releases_path+"\"+$deploy_info.release
    }else {
        $new_release_path = $Null
    }

    return @{
        'clean' = $deploy_info.clean
        'project_path' = $deploy_info.path
        'current_path' = $current_path
        'releases_path' = $releases_path
        'shared_path' = $shared_path
        'previous_release' = $previous_release
        'previous_release_path' = $previous_release_path
        'new_release' = $deploy_info.release
        'new_release_path' = $new_release_path
        'unfinished_filename' = $deploy_info.unfinished_filename
        'keep_releases' = $deploy_info.keep_releases
    }

}

Function Check-Link($link_path, $link_target){
    if (Test-Path -Path $link_path){
        $info_link = Get-Link -link_path $link_path -link_target $link_target
        if ($info_link.Type -ne 0){
            return "exists_but_not_link"
        }
        return $info_link
    }
    return "not_exists"
}

Function Is-Link($path){
    if (Test-Path -Path $path){
        $info_link = Get-Link -link_path $path
        if ($info_link.Type -eq 0){
            return $true
        } else {
            Fail-Json $result "path $path exists but is not a symbolic link"
            return $false
        }
    }

    return $false
}

Function Create-Link($link_path ,$link_target){
    $changed = $false
    $check_link = Check-Link -link_path $facts.current_path -link_target $link_target
    if ($check_link -eq "not_exists")
    {
        $changed += $true
        if (-Not $facts.check_mode)
        {
            New-Link -link_path $facts.current_path -link_target $facts.new_release_path -link_type "link"
        }
    } elseif ( $check_link -eq "exists_but_not_link"){
        Fail-Json $result "path $path exists but is not a symbolic link"
    } else {
        if ($check_link.TargetPath -eq $link_target) {
            $changed += $false
        } else {
            $changed += $true
            if (-Not $facts.check_mode){
                $tmp_link_name = $link_path + '.' + $facts.unfinished_filename

                if (Is-Link -path $tmp_link_name){
                    Remove-Link -link_path $tmp_link_name
                }

                New-Link -link_path $tmp_link_name -link_target $facts.new_release_path -link_type "link"
                Remove-Link -link_path $link_path
                Rename-Item -Path $tmp_link_name -NewName $link_path
            }
        }
    }

    $global:changes += $changed
}

Function Create-Path($path){
    try {
        New-Item -Path $path -ItemType Directory -WhatIf:$check_mode | Out-Null
        $global:changes += $true
    } catch {
        if ($_.CategoryInfo.Category -eq "ResourceExists") {
            $fileinfo = Get-Item $_.CategoryInfo.TargetName
            if ($state -eq "directory" -and -not $fileinfo.PsIsContainer) {
                Fail-Json $result "path $path is not a directory"
            }
        } else {
            Fail-Json $result $_.Exception.Message
        }
    }

}

Function Remove-Unfinished-File($new_release_path){
    $global:changes += $false
    $unfinished_file_path = $new_release_path+'\'+$facts.unfinished_filename
    $result.unfini =$unfinished_file_path
    if (Test-Path -Path $unfinished_file_path){
        $global:changes += $true
        if (-Not $facts.check_mode) {
            Remove-Item -Path $unfinished_file_path -Force
        }
    }
    $global:changes += $changed
}

Function Remove-Unfinished-Link($path){
    $changed += $false

    $tmp_link_name = $path+"\"+$facts.release + '.' + $facts.unfinished_filename

    if ((-Not $facts.check_mode) -And (Test-Path -Path $tmp_link_name)){
        $changed += $true
        Remove-Link -link_path $tmp_link_name
    }

    $global:changes += $changed
}

Function Remove-Unfinished-Builds($releases_path){
    $changed += $false

    $files = Get-ChildItem $releases_path

    for ($i=0; $i -lt $files.Count; $i++) {
        $release = $files[$i].FullName+"\"+$facts.unfinished_filename

        if (Test-Path -Path $release){
            $changed += $true
            if (-Not $facts.check_mode) {
                Remove-Item -Path $files[$i].FullName -Force -Recurse
            }
        }
    }

    $global:changes += $changed
}

Function Cleanup($releases_path, $reserve_version){
    $changed += $false

    if (Test-Path -Path $releases_path){
        $releases = Get-ChildItem $releases_path -Attributes Directory -Exclude $reserve_version | sort -Descending

        for ($i=0; $i -lt ($releases.Count-$facts.keep_releases); $i++) {
            $changed += $true
            if (-Not $facts.check_mode) {
                Remove-Item -Path $releases[$i].FullName -Force -Recurse
            }
        }

    }
    $global:changes += $changed
}

$ansible_facts = @{}
$changes = 0

$facts = Gather-Facts $params_hashtable
$load_links = Load-LinkUtils

if ($state -eq "query")  {
    $ansible_facts.Add("deploy_helper", $facts)

}  elseif ($state -eq "present") {

    Is-Link -path $facts.current_path

    Create-Path -path $facts.project_path
    Create-Path -path $facts.releases_path

    if ($facts.shared_path) {
        Create-Path -path $facts.shared_path
    }

    $ansible_facts.Add("deploy_helper", $facts)

} elseif ($state -eq "finalize") {
    if ($facts.keep_releases -le 0){
        Fail-Json $result "'keep_releases' should be at least 1"
    }

    Remove-Unfinished-File -new_release_path $facts.new_release_path
    Create-Link -link_path $facts.current_path -link_target $facts.new_release_path

    if ($facts.clean){
        Remove-Unfinished-Link -path $facts.project_path
        Remove-Unfinished-Builds -releases_path $facts.releases_path
        Cleanup -releases_path $facts.releases_path -reserve_version $facts.new_release
    }

} elseif ($state -eq "clean") {
    Remove-Unfinished-Link -path $facts.project_path
    Remove-Unfinished-Builds -releases_path $facts.releases_path
    Cleanup -releases_path $facts.releases_path -reserve_version facts.$new_release
} elseif ($state -eq "absent") {
    $ansible_facts.Add("deploy_helper", $facts)
    Remove-Item -Path $facts.project_path -Force -Recurse -WhatIf:$checkmode
}

if ($global:changes -gt 0){
    $result.changed = $true
} else {
    $result.changed = $false
}

$result.ansible_facts += $ansible_facts

Exit-Json -obj $result