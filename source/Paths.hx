package;

import play.song.Song;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxSoundAsset;
import haxe.io.Path;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import util.tools.Preloader;
import play.save.Preferences;

/**
 * A core class used for accessing paths and file locations for images, sounds, etc.
 */
class Paths
{
    /**
     * The extension used for sound files.
     */
    public static inline var SOUND_EXT = "ogg";

    /**
     * Returns true if the game language is NOT English.
     */
    public static function isLocale():Bool
    {
        return Preferences.language != "en-US";
    }

    /**
     * Language file path.
     */
    public static function langaugeFile():String
    {
        return getPath("locale/languages.txt", TEXT, "preload");
    }

    /**
     * Returns the library name from an OpenFL asset path.
     */
    public static function stripLibrary(path:String):String
    {
        return (path.split(":").length > 0) ? path.split(":")[0] : "";
    }

    /**
     * Returns the absolute asset path without the library prefix.
     */
    public static function absolutePath(path:String):String
    {
        return (path.split(":").length > 0) ? path.split(":")[1] : path;
    }

    static function getPath(file:String, type:AssetType, library:Null<String>)
    {
        if (library != null)
            return getLibraryPath(file, library);

        var sharedPath:String = getLibraryPathForce(file, "shared");

        if (OpenFlAssets.exists(sharedPath, type))
            return sharedPath;

        return getPreloadPath(file);
    }

    public static function getLibraryPath(file:String, library:String = "preload")
    {
        return (library == "preload" || library == "default")
            ? getPreloadPath(file)
            : getLibraryPathForce(file, library);
    }

    static inline function getLibraryPathForce(file:String, library:String)
    {
        return '$library:assets/$library/$file';
    }

    static inline function getPreloadPath(file:String)
    {
        return 'assets/$file';
    }

    // -------------------------------------------------------
    // IMAGES
    // -------------------------------------------------------

    public static inline function image(key:String, ?library:String):FlxGraphic
    {
        var assetPath = imagePath(key, library);
        var graphic:FlxGraphic = null;

        if (Preloader.trackedGraphics.exists(assetPath))
            graphic = Preloader.trackedGraphics.get(assetPath);

        else if (Preloader.previousTrackedGraphics.exists(assetPath))
            graphic = cast Preloader.fetchFromPreviousCache(assetPath, IMAGE);

        if (graphic == null)
            graphic = Preloader.cacheImage(assetPath);

        return graphic;
    }

    public static function imagePath(key:String, ?library:String)
    {
        var assetPath:String = getPath('images/$key.png', IMAGE, library);

        if (isLocale())
        {
            var languagePath = getPath('locale/${Preferences.language}/images/$key.png', IMAGE, library);
            if (OpenFlAssets.exists(languagePath))
                assetPath = languagePath;
        }

        return assetPath;
    }

    // -------------------------------------------------------
    // SOUNDS
    // -------------------------------------------------------

    public static function sound(key:String, ?library:String, parentPath:String = "sounds/", ?type:AssetType = SOUND):Sound
    {
        var assetPath = soundPath(key, library, parentPath, type);
        return retrieveSound(assetPath, type);
    }

    public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String):FlxSoundAsset
    {
        return sound(key + FlxG.random.int(min, max), library);
    }

    public static inline function music(key:String, ?library:String)
    {
        return sound(key, library, "music/", MUSIC);
    }

    public static inline function inst(song:String, ?variationId:String, suffix:String = ""):Sound
    {
        var instPath = instPath(song, variationId, suffix);
        return retrieveSound(instPath, MUSIC);
    }

    public static function instPath(song:String, ?variationId:String, suffix:String = ""):String
    {
        var variation = Song.validateVariationPath(variationId);
        return soundPath('${song.toLowerCase()}/Inst${variation}${suffix}', "songs", "", MUSIC);
    }

    public static inline function voices(song:String, ?variationId:String, suffix:String = ""):Sound
    {
        var voicesPath = voicesPath(song, variationId, suffix);
        return retrieveSound(voicesPath, SOUND);
    }

    public static inline function voicesPath(song:String, ?variationId:String, suffix:String = ""):String
    {
        var variation = Song.validateVariationPath(variationId);
        return soundPath('${song.toLowerCase()}/Voices${variation}${suffix}', "songs", "", SOUND);
    }

    public static function soundPath(key:String, ?library:String, ?parentPath:String = "sounds/", ?type:AssetType = SOUND)
    {
        var assetPath:String = getPath('${parentPath}$key.$SOUND_EXT', type, library);

        if (isLocale())
        {
            var languagePath = getPath('locale/${Preferences.language}/${parentPath}$key.$SOUND_EXT', type, library);
            if (OpenFlAssets.exists(languagePath))
                assetPath = languagePath;
        }

        return assetPath;
    }

    static function retrieveSound(key:String, type:AssetType):Sound
    {
        var sound:Sound = null;

        if (Preloader.trackedSounds.exists(key))
            sound = Preloader.trackedSounds.get(key);

        else if (Preloader.previousTrackedSounds.exists(key))
            sound = cast Preloader.fetchFromPreviousCache(key, type);

        if (sound == null)
            sound = Preloader.cacheSound(key);

        return sound;
    }

    // -------------------------------------------------------
    // GENERIC FILES
    // -------------------------------------------------------

    public static inline function file(file:String, type:AssetType = TEXT, ?library:String)
    {
        var assetPath = getPath(file, type, library);

        if (isLocale())
        {
            var languagePath = getPath('locale/${Preferences.language}/$file', type, library);
            if (OpenFlAssets.exists(languagePath))
                assetPath = languagePath;
        }

        return assetPath;
    }

    public static inline function txt(key:String, ?library:String):String
    {
        var assetPath = getPath('data/$key.txt', TEXT, library);

        if (isLocale())
        {
            var languagePath = getPath('locale/${Preferences.language}/data/$key.txt', TEXT, library);
            if (OpenFlAssets.exists(languagePath))
                assetPath = languagePath;
        }

        return assetPath;
    }

    // -------------------------------------------------------
    // ATLASES
    // -------------------------------------------------------

    public inline static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
    }

    public inline static function getPackerAtlas(key:String, ?library:String)
    {
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
    }

    public inline static function atlas(key:String, ?library:String):String
    {
        return Path.withoutExtension(imagePath(key, library));
    }

    // -------------------------------------------------------
    // OTHER FILE TYPES
    // -------------------------------------------------------

    public static inline function font(key:String):String
    {
        return 'assets/fonts/$key';
    }

    public static inline function video(key:String, ?library:String):String
    {
        return getPath('videos/$key.mp4', BINARY, library);
    }

    public static inline function data(key:String, ?library:String):String
    {
        return getPath('data/$key', TEXT, library);
    }

    public static function offsetFile(character:String):String
    {
        return getPath('data/offsets/$character.txt', TEXT, "preload");
    }

    public static inline function json(key:String, ?library:String):String
    {
        return getPath('data/$key.json', TEXT, library);
    }

    public static inline function chart(key:String, ?library:String):String
    {
        return getPath('data/charts/$key.json', TEXT, library);
    }

    public static inline function script(key:String, ?library:String):String
    {
        return getPath('data/scripts/$key', TEXT, library);
    }

    public static inline function frag(key:String, ?library:String)
    {
        return getPath('data/shaders/${key}.frag', TEXT, library);
    }
}
