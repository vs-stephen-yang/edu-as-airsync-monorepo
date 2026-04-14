#pragma once
#include <windows.h>
#include <msi.h>
#include <msiquery.h>

// Define import/export macro
#ifdef CUSTOMACTIONS_EXPORTS
#define CUSTOMACTIONS_API extern "C" __declspec(dllexport)
#else
#define CUSTOMACTIONS_API extern "C" __declspec(dllimport)
#endif

CUSTOMACTIONS_API UINT __stdcall InstallAudio(MSIHANDLE hInstall);
CUSTOMACTIONS_API UINT __stdcall UninstallAudio(MSIHANDLE hInstall);
