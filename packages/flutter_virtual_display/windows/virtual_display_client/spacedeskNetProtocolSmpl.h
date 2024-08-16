#pragma once

#define PROTOCOL_SPCDSK_SMPL_CURRENT_VERSION_MAJOR 4
#define PROTOCOL_SPCDSK_SMPL_CURRENT_VERSION_MINOR 8

#define PROTOCOL_SPCDSK_IP_PORT_TCP_MAIN_SERVER 28252

#define PROTOCOL_V3DDK_DISCOVERY_BROADCAST_MESSAGE "SPACEDESK-NET-CLIENT"

#define MAX_RESOLUTION_ARRAY_SIZE 9

#define PROTOCOL_SPCDSK_INP_TOUCH_FLAG_ABSOLUTE                 1
#define PROTOCOL_SPCDSK_INP_TOUCH_FLAG_DOWN                     2
#define PROTOCOL_SPCDSK_INP_TOUCH_FLAG_UP                       4
#define PROTOCOL_SPCDSK_INP_KEYBOARD_FLAG_DOWN                  1
#define PROTOCOL_SPCDSK_INP_KEYBOARD_FLAG_UP                    2
#define PROTOCOL_SPCDSK_INP_KEYBOARD_FLAG_UNICODE               4
#define PROTOCOL_SPCDSK_INP_KEYBOARD_FLAG_DOWN_UP_EMULATION     0x8000  // Sent by Android client to emulate both key down and up in server side. 
                                                                        // This is workaround to missing/lost KeyUp network packet.

#define PROTOCOL_SPCDSK_FEATURE_SUPPORT_DISCOVERY_OS_VERSION_ONLY_VALID_COMBINED_WITH_PEN_SUPPORT   1
#define PROTOCOL_SPCDSK_FEATURE_SUPPORT_BIT_DEVICE_HID_PEN                                          2

typedef enum _PROTOCOL_SPCDSK_SMPL_HEADER_TYPE
{
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_IDENTIFICATION,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_PING,

    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_FRAMEBUFFER,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_VISIBILITY,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_CURSOR_POSITION,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_CURSOR_BITMAP,

    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_POWER_SUSPEND_HIBERNATE,

    // Events from client to server
    PROTOCOL_SPACEDESK_FRAMEBUFFER_FLOW_CONTROL_ACK,
    PROTOCOL_SPACEDESK_DISCONNECT,
    PROTOCOL_SPACEDESK_ROTATION,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_EVT_INPUT_MOUSE,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_EVT_INPUT_KEYBOARD,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_EVT_INPUT_TOUCH,
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_EVT_INPUT_PEN,

    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_MAX // for plausibility checks

} PROTOCOL_SPCDSK_SMPL_HEADER_TYPE;

typedef enum _PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE
{
    PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_DISPLAY_MONITOR,
    PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_DISPLAY_MONITOR_WEB_BROWSER,   // TBD: To be removed in future protocol version
    PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_RESERVED_01,                   // TBD: To be removed in future protocol version
    PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_RESERVED_02, // PROTOCOL_SPCDSK_INP_CLIENT_TYPE_KTM,

    PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE_MAX,   // For plausibility checks

} PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE;

typedef enum _PROTOCOL_SPCDSK_SMPL_OS_TYPE
{
    PROTOCOL_SPCDSK_SMPL_OS_TYPE_UNKNOWN,
    PROTOCOL_SPCDSK_SMPL_OS_TYPE_WINDOWS_NATIVE,
    PROTOCOL_SPCDSK_SMPL_OS_TYPE_WINDOWS_UWP,
    PROTOCOL_SPCDSK_SMPL_OS_TYPE_ANDROID,
    PROTOCOL_SPCDSK_SMPL_OS_TYPE_IOS,

    PROTOCOL_SPCDSK_NET_SMPL_OS_TYPE_MAX,

} PROTOCOL_SPCDSK_SMPL_OS_TYPE;

typedef enum _PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE
{
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_UNKNOWN,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_SERVER_R2_2008,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_7,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_SERVER_2012,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_8_0,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_SERVER_R2_2012,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_8_1,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_SERVER_2016,
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE_WINDOWS_10,

    PROTOCOL_SPCDSK_NET_SMPL_SERVER_OS_TYPE_MAX,

} PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE;

typedef enum _PROTOCOL_SPCDSK_SMPL_COMPRESSION_TYPE
{
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_OFF,
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_YUV_PLAIN,
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_MPEG,
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_MJPEG_D1_00,
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_MJPEG_D2_00,
    PROTOCOL_SPCDSK_SMPL_COMPRESSION_DMPEG_EXPERIMENTAL,
    PROTOCOL_SPCDSK_SMPL_MAX,

} PROTOCOL_SPCDSK_SMPL_COMPRESSION_TYPE, *PPROTOCOL_SPCDSK_SMPL_COMPRESSION_TYPE;

typedef enum _PROTOCOL_SPCDSK_COLORSPACE_YUV
{
    PROTOCOL_SPCDSK_SMPL_COLORSPACE_YUV_4_4_4 = 0, 
    PROTOCOL_SPCDSK_SMPL_COLORSPACE_YUV_4_2_2,
    PROTOCOL_SPCDSK_SMPL_COLORSPACE_YUV_4_2_0,
    PROTOCOL_SPCDSK_SMPL_COLORSPACE_YUV_MAX,

} PROTOCOL_SPCDSK_COLORSPACE_YUV, * PPROTOCOL_SPCDSK_COLORSPACE_YUV;


typedef union _PROTOCOL_SPCDSK_SMPL_COMPRESSION_INFO
{
    struct 
    {
        PROTOCOL_SPCDSK_COLORSPACE_YUV Subsampling;
        LONG Quality;
    } Jpeg;

    struct 
    {
        LONG Reseved1;
        LONG Reseved2;
        LONG Reseved3;
        LONG Reseved4;
    } Reserved;

} PROTOCOL_SPCDSK_SMPL_COMPRESSION_INFO, *PPROTOCOL_SPCDSK_SMPL_COMPRESSION_INFO;

typedef struct _PROTOCOL_SPCDSK_SMPL_HEADER
{
    _PROTOCOL_SPCDSK_SMPL_HEADER()
        :   HeaderType(PROTOCOL_SPCDSK_SMPL_HEADER_TYPE_MAX),
            CountbyteDataFollowingHeader(0)
    {
    }
    PROTOCOL_SPCDSK_SMPL_HEADER_TYPE HeaderType;
    ULONG CountbyteDataFollowingHeader;

    union
    {
        struct 
        {
            LONG ProtocolVersionNumberMajor;
            LONG ProtocolVersionNumberMinor;
            PROTOCOL_SPCDSK_SMPL_CLIENT_TYPE ClientType;
            PROTOCOL_SPCDSK_SMPL_OS_TYPE OsType;
            PROTOCOL_SPCDSK_SMPL_COMPRESSION_TYPE CompressionTypeDesired;
            PROTOCOL_SPCDSK_SMPL_COMPRESSION_INFO CompressionInfoDesired;
            SHORT FrameRateLimitation;
            SHORT Reserved;
            LONG ResolutionsListCount;
            LONG ResolutionX[MAX_RESOLUTION_ARRAY_SIZE];
            LONG ResolutionY[MAX_RESOLUTION_ARRAY_SIZE];
            LONG LicensingInformation;

        } Identification;

        struct 
        {
            LONG Width;
            LONG Height;
            LONG Pitch;
            LONG Format;
            RECT PartialUpdateRect;
            PROTOCOL_SPCDSK_SMPL_COMPRESSION_TYPE CompressionType;
            PROTOCOL_SPCDSK_SMPL_COMPRESSION_INFO CompressionInfo;
            SHORT Reserved01;
            SHORT Reserved02;
            LONG FragmentInfo;
            LONG CountByteBufferCompressed;

        } FrameBuffer;

        struct 
        {
            LONG IsVisible;

        } Visibility;

        struct 
        {
            LONG X;
            LONG Y;
            LONG Show;
            LONG Reserved1;
            RECT Reserved2;

        } Cursor;

        struct 
        {
            LONG Width;
            LONG Height;
            LONG Pitch;
            LONG XHot;
            LONG YHot;
            LONG Flags;
            RECT Reserved1;

        } CursorBitmap;

        struct
        {
            LONG Rotation; // DISPLAYCONFIG_ROTATION enum

        } DisplayRotation;

        struct
        {
            LONG X;
            LONG Y;
            DWORD ButtonData;
            DWORD ButtonFlags;
            DWORD Flags;

        } EvtInputMouse;

        struct
        {
            LONG  VKeyCode;
            LONG  ScanCode;
            DWORD Flags;
            DWORD Time;
            DWORD Reserved;

        } EvtInputKeyboard;

        struct
        {
            LONG X;
            LONG Y;
            LONG ResolutionX;
            LONG ResolutionY;
            DWORD Flags;
            DWORD TimestampMilliseconds;

        } EvtInputTouch;

        struct
        {
            LONG ResolutionX;
            LONG ResolutionY;
            FLOAT X;
            FLOAT Y;
            FLOAT tiltX;
            FLOAT tiltY;
            FLOAT Pressure;
            BOOLEAN bContact;
            BOOLEAN bEraser;
            BOOLEAN bBarrelPressed;
            BOOLEAN bInRange;

        } EvtInputPen;

    } u;

} PROTOCOL_SPCDSK_SMPL_HEADER, *PPROTOCOL_SPCDSK_SMPL_HEADER;

typedef struct _PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION
{
    wchar_t DeviceIdentifier[39];   // Unique identification key for each device.
    wchar_t DeviceInformation[128]; // Additional info, not necessarily unique.

} PROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION, *PPROTOCOL_SPCDSK_SMPL_DATA_IDENTIFICATION;

typedef struct _PROTOCOL_V3DDK_DISCOVERY_HOST_INFO
{
    wchar_t Hostname[MAX_HOSTNAME_LEN];
    ULONG IpAddress;
    USHORT Port;

} PROTOCOL_V3DDK_DISCOVERY_HOST_INFO, *PPROTOCOL_V3DDK_DISCOVERY_HOST_INFO;

typedef struct _PROTOCOL_V3DDK_DISCOVERY_HOST_INFO2
{
    PROTOCOL_V3DDK_DISCOVERY_HOST_INFO Identification;
    PROTOCOL_SPCDSK_SMPL_SERVER_OS_TYPE ServerOsType;
    ULONG ServerOsBuildNumber;
    LONG SpacedeskProtocolVersionNumberMajor;
    LONG SpacedeskProtocolVersionNumberMinor;
    ULONG SpacedeskBitmapFeatures1;
    ULONG SpacedeskBitmapFeatures2;
    ULONG Reserved1;
    ULONG Reserved2;
    ULONG Reserved3;
    ULONG Reserved4;
    ULONG Reserved5;

} PROTOCOL_V3DDK_DISCOVERY_HOST_INFO2, * PPROTOCOL_V3DDK_DISCOVERY_HOST_INFO2;