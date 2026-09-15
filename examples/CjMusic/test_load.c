#include <windows.h>
#include <stdio.h>

int main() {
    HMODULE h = LoadLibraryA("C:\\CodeTools\\cangjie_git\\CJQT6\\examples\\CjMusic\\target\\release\\bin\\cjqt6_bridge.dll");
    if (h == NULL) {
        printf("LoadLibrary failed: %lu\n", GetLastError());
        return 1;
    }
    printf("LoadLibrary succeeded: %p\n", h);
    FreeLibrary(h);
    return 0;
}