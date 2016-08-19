PopupCreator = angular.module( 'popupCreator', [] )

PopupCreator.controller 'popupCtrl', ['$scope', ($scope) ->
	$scope.widget =
		engineName: ""
		title     : ""

	$scope.state =
		isEditingExistingWidget: false

	$scope.initNewWidget = (widget) ->
		$scope.$apply ->
			$scope.widget.engineName = $scope.widget.title = widget.name

	$scope.initExistingWidget = (title, widget, qset, version, baseUrl) ->
		$scope.state.isEditingExistingWidget = true
		$scope.$apply ->
			$scope.widget.engineName = widget.name
			$scope.widget.title     = title

	$scope.onSaveClicked = (mode = 'save') ->
		if $scope.widget.title
			Materia.CreatorCore.save $scope.widget.title, _buildSaveData()
		else Materia.CreatorCore.cancelSave 'This widget has no title!'

	$scope.onSaveComplete = (title, widget, qset, version) -> null

	$scope.onMediaImportComplete = (media) -> null

	# Private methods
	_buildSaveData = ->
		name    : ''
		items   : []


	Materia.CreatorCore.start $scope
]