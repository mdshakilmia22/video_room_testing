allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// agora_rtc_engine falls back to compileSdkVersion 31 and minSdkVersion 21
// when the root project does not expose them, which is too old for the
// androidx libraries the plugin depends on.
extra["compileSdkVersion"] = 35
extra["minSdkVersion"] = 24

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
