#
# Exports an array of diagram streams representing the input diagrams.
#
Rx = require 'rx'
Examples = require 'rxmarbles/models/examples'
SelectedExample = require 'rxmarbles/controllers/selected-example'
Utils = require 'rxmarbles/controllers/utils'
Sandbox = require 'rxmarbles/views/sandbox'

arrayOfInitialInputDiagrams$ = new Rx.BehaviorSubject(null)

prepareNotification = (input) ->
  if typeof input.time isnt "undefined"
    return input
  output = {
    time: input.t
    content: input.d
  }
  output.id = Utils.calculateNotificationHash(output)
  return output

getNotifications = (diagram) ->
  [..., last] = diagram
  if typeof last is 'number'
    return diagram.slice(0,-1)
  else
    return diagram

prepareInputDiagram = (diagram, indexInArray = 0) ->
  notifications = getNotifications(diagram)
  [..., last] = diagram
  preparedDiagram = (prepareNotification(n) for n in notifications)
  preparedDiagram.end = if typeof last is 'number' then last else 100
  preparedDiagram.id = indexInArray
  return preparedDiagram

SelectedExample.stream
  .map((example) -> example["inputs"].map(prepareInputDiagram))
  .subscribe((arrayOfDiagrams) ->
    arrayOfInitialInputDiagrams$.onNext(arrayOfDiagrams)
    return true
  )

continuous$ = Sandbox.getStreamOfArrayOfLiveInputDiagramStreams()

module.exports = {
  initial$: arrayOfInitialInputDiagrams$
  continuous$: continuous$
}
