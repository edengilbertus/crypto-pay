allprojects {
    repositories {
        google()
        mavenCentral()
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

// Force plugin modules (e.g. coinbase_wallet_sdk) onto a modern compileSdk.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { androidExt ->
            val setCompileSdk = androidExt.javaClass.methods.find {
                it.name == "setCompileSdk" && it.parameterCount == 1
            }
            val getCompileSdk = androidExt.javaClass.methods.find {
                it.name == "getCompileSdk" && it.parameterCount == 0
            }
            val current = getCompileSdk?.invoke(androidExt)
            if (current is Int && current < 35) {
                setCompileSdk?.invoke(androidExt, 36)
                logger.lifecycle("Forced compileSdk 36 on ${project.path} (was $current)")
            } else if (current is Number && current.toInt() < 35) {
                setCompileSdk?.invoke(androidExt, 36)
                logger.lifecycle("Forced compileSdk 36 on ${project.path} (was $current)")
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
