#include <jni.h>
#include <string>
#include <android/log.h>

#define LOG_TAG "PushTrial16KB"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jstring JNICALL
Java_com_ckessentiel_pushtrial_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "16 KB Page Size Support Enabled";
    LOGI("16 KB page size support initialized");
    return env->NewStringUTF(hello.c_str());
}

// Function to verify 16 KB page size support
extern "C" JNIEXPORT jboolean JNICALL
Java_com_ckessentiel_pushtrial_MainActivity_supports16KBPages(
        JNIEnv* env,
        jobject /* this */) {
    
    #ifdef ANDROID_LARGE_PAGE_SIZE_SUPPORT
        LOGI("16 KB page size support is enabled");
        return JNI_TRUE;
    #else
        LOGI("16 KB page size support is not enabled");
        return JNI_FALSE;
    #endif
}
