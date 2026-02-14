allprojects {
    repositories {
        google()
        mavenCentral()
        // Mapbox Maven repository - REQUIRED for Mapbox Maps SDK
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            credentials {
                username = "mapbox"
                // Use the secret token from strings.xml or set directly
                password = "sk.eyJ1IjoiY29kZWJ5c2F0eWFqaXQiLCJhIjoiY21sa3RjczM5MDBxbDJqcHR1d25uZHRycSJ9.ZGLy8-L2i3pYx6Fc-hhLww"
            }
            authentication {
                create<BasicAuthentication>("basic")
            }
        }
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
