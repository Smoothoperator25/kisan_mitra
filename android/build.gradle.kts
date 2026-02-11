allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Force Kotlin stdlib 1.9.24 across all modules to avoid metadata version mismatch
    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.24")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.24")
            force("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
            force("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
            force("org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.7.3")
        }
    }
}

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
