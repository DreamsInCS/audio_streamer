import Flutter
import UIKit
import AVFoundation

public class SwiftAudioStreamerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventSink: FlutterEventSink?
  var engine = AVAudioEngine()
  var audioData: [Float] = []
  var recording = false
  let sampleRate = 22050.0

  // Register plugin
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAudioStreamerPlugin()

    // Set flutter communication channel for emitting updates
    let eventChannel = FlutterEventChannel.init(name: "audio_streamer.eventChannel", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  // Handle stream emitting (Swift => Flutter)
  private func emitValues(values: [Float]) {
      // If no eventSink to emit events to, do nothing (wait)
      if (eventSink == nil) {
          return
      }
      // Emit values count event to Flutter
      eventSink!(values)
  }

  // Event Channel: On Stream Listen
  public func onListen(withArguments arguments: Any?,
    eventSink: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = eventSink
    if #available(iOS 9.0, *) {
        startRecording()
    } else {
        // Important note: Can cause audio distortion
        startRecordingOld()
    }
      return nil
  }

  // Event Channel: On Stream Cancelled
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      NotificationCenter.default.removeObserver(self)
      eventSink = nil
      engine.stop()
      //self.emitValues(values: audioData)
      return nil
  }

    @available(iOS 9.0, *)
    public func startRecording() {
      engine = AVAudioEngine()
        
      let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)!
      let bus = 0
      let input = engine.inputNode
      let inputFormat = input.outputFormat(forBus: bus)
      let converter = AVAudioConverter(from: input.inputFormat(forBus: bus), to: outputFormat)!
  
      try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record)
        
      input.installTap(onBus: bus, bufferSize: AVAudioFrameCount(sampleRate), format: inputFormat) { (buffer, time) -> Void in
      var newBufferAvailable = true

      let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            if newBufferAvailable {
                  outStatus.pointee = .haveData
                  newBufferAvailable = false
                  return buffer
            } else {
                outStatus.pointee = .noDataNow
                return nil
            }
      }

      let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(outputFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))!

      var error: NSError?
      let status = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputCallback)
      assert(status != .error)

      let samples = convertedBuffer.floatChannelData?[0]
      let arr = Array(UnsafeBufferPointer(start: samples, count: Int(convertedBuffer.frameLength)))
        
      self.emitValues(values: arr)
    }

      try! engine.start()
  }
    
    public func startRecordingOld() {
        let bus = 0
        let input = engine.inputNode
        engine = AVAudioEngine()
      
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record)
        try! AVAudioSession.sharedInstance().setPreferredSampleRate(sampleRate)

        input.installTap(onBus: bus, bufferSize: AVAudioFrameCount(sampleRate), format: input.outputFormat(forBus: bus)) { (buffer, time) -> Void in
            let samples = buffer.floatChannelData?[0]
            let arr = Array(UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
            
            self.emitValues(values: arr)
        }

        try! engine.start()
  }
}
