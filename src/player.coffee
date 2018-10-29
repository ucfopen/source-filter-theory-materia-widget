SourceFilterTheory = angular.module 'sourceFilterTheory', []

SourceFilterTheory.controller 'sourceFilterTheoryCtrl', ['$scope', '$timeout',  ($scope, $timeout) ->
	$scope.currentStep = 1
	$scope.maxStep = 15

	$scope.definition = false
	$scope.startFade = false
	definitionTimer = false

	$scope.vocalTractClicked = false
	$scope.vocalFoldsClicked = false

	$scope.standaloneClicked = false

	audio = null

	terms = [
		"Vocal Folds are multi-layered folds of tissue that vibrates or opens and closes rapidly releasing puffs of air into the vocal tract. This is the beginning of a sound wave.",
		"Vibrating Vocal Folds: We never heard the pure sound of the vibrating vocal folds because this sound is always modified or 'filtered' by the vocal tract. The sound source of phonation is modified or filtered into the various vowel sounds by the particular shape of the vocal tract.",
		"Vocal Tract: The means by which we filter the sound source of the vibrating vocal folds into various vowel sounds is by the position of the tongue. Depending on how high or low the tongue is, there will be a different sized and shaped 'oral cavity' and the size and shape of the 'pharyngeal cavity' will also be affected.",
		"Fundamental Frequency (100Hz) is the lowest frequency.",
		"Harmonic: a vibration that is an integral multiple of the fundamental frequency. The following harmonics drop off in amplitude (the rate of 12 db after doubling the fundamental frequency).",
		"F1 and F2 are the formants (or resonances) of the vocal tract or peaks of harmonic energy. The F1 relates to the pharyngeal cavity; F2 relates to the oral cavity."
	]

	$scope.stepForward = ->
		unless $scope.currentStep == $scope.maxStep
			$scope.currentStep++
			pageActions()
	$scope.stepBack = ->
		unless $scope.currentStep == 1
			$scope.currentStep--
			pageActions()

	pageActions = ->
		if audio then audio.pause()
		switch $scope.currentStep
			when 4
				$scope.vocalFoldsClicked = false
			when 5
				$scope.vocalTractClicked = false
				$scope.vocalFoldsClicked = false
			when 6, 7, 9, 10
				$scope.standaloneClicked = false
			when 11
				$scope.playAudio 'eeNormal'
			when 12
				$scope.playAudio 'eeHigh'
			when 13
				$scope.playAudio 'ah'
			when 14
				$scope.playAudio 'oo'

	$scope.playAudio = (sound) ->
		if audio then audio.pause()
		audio = new Audio 'assets/audio/'+sound+'.mp3'
		audio.play()

	$scope.modalDefine = (term) ->
		$scope.definition = terms[term]

	$scope.closeDefinition = ->
		$scope.startFade = true
		definitionTimer = $timeout ->
			$scope.definition = false
			$scope.startFade = false
			$scope.$apply()
		, 1000
]
