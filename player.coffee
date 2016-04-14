Namespace('SourceFilterTheory').Engine = do ->
	_qset                   = null
	_currentQuestion        = null
	_$currentQuestionSphere = null
	_currentQuestionIndex   = null
	_$board                 = null
	_qs                     = null
	_questions              = {}
	_scores                 = []
	_totalQuestions         = 0
	_answeredQuestions      = 0
	_currentScore           = 0
	_finalScore             = 0
	_$remainingQuestions    = null

	# Called by Materia.Engine when your widget Engine should start the user experience.
	start = (instance, qset, version = '1') ->
		_qset = qset
		_drawBoard(instance.name)

		# Set player height.
		Materia.Engine.setHeight()

	# Shuffle any array.
	_shuffle = (a) ->
		if a.length is 1
			return a
		for i in [a.length-1..1]
			j = Math.floor Math.random() * (i + 1)
			[a[i], a[j]] = [a[j], a[i]]
		a

	# Draw the main board.
	_drawBoard = (title) ->
		tBoard = _.template $('#t-board').html()
		_$board = $(tBoard title: title, questions: _qset.items)

		# Make an array of each questions, and count the questions.
		for question in _qset.items
			question.answers = _shuffle(question.answers) if _qset.options.randomize
			_totalQuestions++
			_questions[question.id] = question

		_$board.on 'click', _onBoardQuestionClick

		$('body').append _$board

	#handles the button actions on the Question Page.
	_setUpQuestionPageButtons = ($currQuestion, clickedSphere) ->
		# Set up the button listeners.
		$currQuestion.on 'click', '.return', ->
			_closeQuestion()

		$currQuestion.on 'click', '.submit', _submitAnswer
		$currQuestion.find('.answers input').on 'click', (clickedSphere) ->
			if not $(clickedSphere.target).parent().parent('li').hasClass 'selected'
				$('.button-checked').fadeOut(100)
				$(this).parent().find('.button-checked').fadeIn(100)
			$('.answers li').removeClass 'selected'
			$(clickedSphere.target).parent().parent('li').addClass 'selected'
			$currQuestion.find('.button.submit').prop 'disabled', false

	# When a question on the main board is clicked Draw the Question Page.
	_onBoardQuestionClick = (clickedSphere) ->
		# Set the current question.
		_$currentQuestionSphere = $(clickedSphere.target)

		#if the question is already answered, do not do anything when clicked.
		return unless _$currentQuestionSphere.hasClass('unanswered')

		_currentQuestion = _questions[_$currentQuestionSphere.data('id')]
		_currentQuestionIndex = parseInt _$currentQuestionSphere.html(), 10

		# Draw the Question Popup Page.
		tQuestion = _.template $('#t-question-page').html()
		$question = $ tQuestion
			index: _currentQuestionIndex
			id: _currentQuestion.id
			answers: _currentQuestion.answers
			question: _currentQuestion.questions[0].text

		qStyle = $question[0].children[0]

		#call button setup.
		_setUpQuestionPageButtons($question, clickedSphere)

		$('body').append $question
		qStyle.className = 'question-popup shown'

	# Grade answer from SubmitAnswer.
	_GradeQuestion = (answer, questionForGrade, $chosen) ->
		# send answer to scoring module and add score to list.
		Materia.Score.submitQuestionForScoring questionForGrade.id, answer.text
		_scores.push answer.score
		_updateScore()

		# Add a check if the user is correct.
		if answer.score == 100
			$chosen.parents('li').prepend("&#x2713;")
			$('.correct').fadeIn()
			_$currentQuestionSphere
				.addClass('correct')
				.html('&#x2713;')

		# Add an X if a the user is wrong.
		else if answer.score == 0
			$chosen.parents('li').prepend('X')
			$('.wrong').fadeIn()
			_$currentQuestionSphere
				.addClass('wrong')
				.html('X')

		# Partial credit
		else
			$chosen.parents('li').prepend('&asymp;')
			$('.partial').fadeIn()
			_$currentQuestionSphere
				.addClass('correct')
				.addClass('partial')
				.html(answer.score + '%')

		# Update the radio list and buttons.
		$(".answers input[type='radio']").prop 'disabled', true
		$('.button.submit').prop 'disabled', true
		$('.button.return').addClass 'highlight'
		$('.answers ul').addClass('answered')
		_$currentQuestionSphere.removeClass('unanswered')

	# Answer submitted by user.
	_submitAnswer = ->
		
		$chosenRadio = $(".answers input[type='radio']:checked")
		chosenAnswer = $chosenRadio.val()
		answer = _checkAnswer _currentQuestion, chosenAnswer
		_GradeQuestion(answer, _currentQuestion, $chosenRadio)

	# Update the user's score.
	_updateScore = ->
		_answeredQuestions++
		total = 0
		for i in [0.._scores.length - 1]
			total += _scores[i]

		_currentScore = Math.round total / _answeredQuestions
		_finalScore   = Math.round total / _totalQuestions

	# Check the value of the chosen answer
	_checkAnswer = (question, answerId) ->
		for answer in question.answers
			if String(answer.id) == String(answerId)
				return {
					score: parseInt(answer.value, 10)
					text: answer.text
				}
		throw Error 'Submitted answer not in this question'

	# Draw the final screen that transitions to the Score Screen
	_drawFinishScreen = ->
		# End, but don't show the score screen yet
		Materia.Engine.end no
		tFinish = _.template $('#t-finish-notice').html()
		$finish = $(tFinish score: _finalScore)
		$finish.find('button').on 'click', _end
		_$board.hide()
		$('body').append $finish

		# Adjust HTML depending on user results.
		scorebox = document.getElementById('scorebox_final')

		# The user has answered something correctly.
		if _finalScore != 0
			scorebox.children[1].innerHTML = _finalScore

			# The user has full credit.
			if _finalScore is 100
				scorebox.children[1].className = 'value all-correct'
				scorebox.children[2].className = 'percent all-correct'

			# The user has partial credit.
			else
				scorebox.children[3].innerHTML = (100 - _finalScore) + '% wrong'

		# The user has answered everything incorrectly.
		else
			scorebox.children[1].innerHTML = _finalScore
			scorebox.children[1].className = 'value all-wrong'
			scorebox.children[2].className = 'percent all-wrong'

	# Close a Question screen to return to the main board.
	_closeQuestion = ->
		$('.screen.question').remove()
		
		#if all question have been answered, go to finish screen.
		_drawFinishScreen() if _scores.length == _totalQuestions

	_end = ->
		Materia.Engine.end yes

	#public
	manualResize: true
	start: start

