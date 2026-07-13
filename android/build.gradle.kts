allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        tasks.matching { it.name == "compileDebugKotlin" }.configureEach {
            val javaTask = project.tasks.findByName("compileDebugJavaWithJavac") as? JavaCompile
            if (javaTask != null) {
                val target = javaTask.targetCompatibility
                (this as org.jetbrains.kotlin.gradle.tasks.KotlinCompile).compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(target.toString()))
                }
            }
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
