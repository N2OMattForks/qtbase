import qbs
import qbs.File
import qbs.FileInfo
import qbs.TextFile
import "qbs/imports/QtUtils/qtutils.js" as QtUtils
import QtMultiplexConfig

Project {
    property string qtbaseShadowDir: {
        var topLevelShadowDir = FileInfo.cleanPath(FileInfo.joinPaths(buildDirectory, ".."));
        var possibleQtBaseDir = FileInfo.joinPaths(topLevelShadowDir, "qtbase");
        if (File.exists(possibleQtBaseDir))
            return possibleQtBaseDir;
        return topLevelShadowDir;
    }
    property bool isShadowBuild: path !== qtbaseShadowDir
    property string configPath: qtbaseShadowDir + "/src/corelib/global" // TODO: try to get rid of this
    qbsSearchPaths: ["qbs", qtbaseShadowDir + "/qbs"]

    property bool debugAndRelease: QtMultiplexConfig.debug_and_release
    property stringList targetArchitecture: QtMultiplexConfig.architecture
    property stringList toolchain: QtMultiplexConfig.toolchain

    Profile {
        name: "qt_hostProfile"
        qbs.toolchain: QtMultiplexConfig.hostToolchain
        cpp.compilerName: QtMultiplexConfig.hostCompilerName
        cpp.toolchainInstallPath: QtMultiplexConfig.hostToolchainInstallPath
    }

    QtTargetProfile {
        name: "qt_targetProfile"
        qbs.toolchain: project.toolchain
        qbs.targetPlatform: QtMultiplexConfig.platform
        cpp.compilerName: QtMultiplexConfig.compilerName
        cpp.toolchainInstallPath: QtMultiplexConfig.toolchainInstallPath
    }

    Probe {
        id: versionProbe

        // inputs
        property string qmakeConfFilePath: path + "/.qmake.conf"
        property var qmakeConfTimestamp: File.lastModified(qmakeConfFilePath)

        // outputs
        property string version

        configure: {
            var qmakeConfFile;
            try {
                qmakeConfFile = new TextFile(qmakeConfFilePath);
                var qmakeConf = qmakeConfFile.readAll();
                version = qmakeConf.match(/^MODULE_VERSION = (\d\d?\.\d\d?\.\d\d?)$/m)[1];
                found = true;
            } finally {
                if (qmakeConfFile)
                    qmakeConfFile.close();
            }
        }
    }

    readonly property string version: versionProbe.version
    readonly property var versionParts: version.split('.').map(function(part) { return parseInt(part); })
    property string qtbaseDir: path

    readonly property path binDirectory: buildDirectory + "/bin"
    readonly property path libDirectory: buildDirectory + "/lib"
    readonly property path jarDirectory: buildDirectory + "/jar"

    references: [
        // "examples/examples.qbs",
        "src/src.qbs",
//        "tests",
    ]
}