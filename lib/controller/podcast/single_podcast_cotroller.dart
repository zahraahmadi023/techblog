

import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tec/constant/api_constant.dart';
import 'package:tec/models/podcasts_file_model.dart';
import 'package:tec/services/dio_service.dart';

class SinglePodcastController extends GetxController{

  var id;
  
  SinglePodcastController({this.id});

  RxBool loading  = false.obs;
  RxList<PodcastsFileModel> podcastFileList = RxList();
  final player = AudioPlayer();
  late ConcatenatingAudioSource playList;
  RxBool playState = false.obs;
  RxInt currentFileIndex = 0.obs;
  @override
  onInit() async {
    super.onInit();
    playList  = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: []);
    
    await getPodcastFiles();
    await player.setAudioSource(playList,initialIndex: 0,initialPosition: Duration.zero);

  }

  getPodcastFiles() async {
    loading.value = true;

    var response = await DioSevice().getMethod(ApiUrlConstant.podcastFiles+id);

    if (response.statusCode==200) {

      for (var element in response.data["files"]) {
        var podcastFileModel = PodcastsFileModel.fromJson(element);
        podcastFileList.add(podcastFileModel);
        playList.add(AudioSource.uri(Uri.parse(podcastFileModel.file!)));
      }
      loading.value =false;  
    }


  }

  

  Rx<Duration> progressValue = Duration(seconds: 0).obs;
  Rx<Duration> bufferedValue = Duration(seconds: 0).obs;

  Timer? timer;


  startProgress(){
    const tick = Duration(seconds: 1);
    int duration = player.duration!.inSeconds - player.position.inSeconds ;

    if (timer!=null) {
      if (timer!.isActive) {
        timer!.cancel();
        timer=null;
      }
    }

    timer = Timer.periodic(tick, (timer) {
      
      duration--;
      progressValue.value = player.position;
      bufferedValue.value = player.bufferedPosition;
      if (duration<=0) {
        timer.cancel();
        progressValue.value = Duration(seconds: 0);
        bufferedValue.value = Duration(seconds: 0);
      }

    });


  }


}