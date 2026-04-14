#include <iostream>
#include <windows.h>
#include <string>
#include <vector>

std::vector<std::wstring> parseArguments(int argc, wchar_t* argv[]) {
    std::vector<std::wstring> args;
    for (int i = 1; i < argc; ++i) {
        args.push_back(argv[i]);
    }
    return args;
}

std::wstring getExecutablePath() {
    wchar_t buffer[MAX_PATH];
    GetModuleFileNameW(NULL, buffer, MAX_PATH);
    std::wstring::size_type pos = std::wstring(buffer).find_last_of(L"\\/");
    return std::wstring(buffer).substr(0, pos);
}

int APIENTRY wWinMain(
        HINSTANCE hInstance,
        HINSTANCE hPrevInstance,
        LPWSTR    lpCmdLine,
        int       nCmdShow)
{
    int argc;
    wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    std::vector<std::wstring> args = parseArguments(argc, argv);
    LocalFree(argv);

    std::wstring exe;
    std::wstring parameters;
    std::wstring workdir = getExecutablePath(); // Default to launcher.exe's directory

    for (size_t i = 0; i < args.size(); ++i) {
        if (args[i].find(L"--exe=") == 0) {
            exe = args[i].substr(6);
        } else if (args[i].find(L"--args=") == 0) {
            parameters = args[i].substr(7);
        } else if (args[i].find(L"--workdir=") == 0) {
            workdir = args[i].substr(10);
        }
    }

    if (exe.empty()) {
        std::wcerr << L"Error: No executable specified." << std::endl;
        return 1;
    }

    HINSTANCE hInst = ShellExecuteW(
        NULL,           // hWnd
        L"open",   // Operation to perform
        exe.c_str(),    // Path to the executable
        parameters.c_str(),  // Parameters to pass to the executable
        workdir.c_str(),    // Default directory
        SW_SHOWNORMAL   // Window show command
    );

    if ((INT_PTR)hInst <= 32) {
        std::wcerr << L"Error: " << (int)(INT_PTR)hInst << std::endl;
        return 1;
    }

    return 0;
}
