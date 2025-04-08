import '/chatwoot_callbacks.dart';
import '/chatwoot_parameters.dart';
import '/di/modules.dart';

/// Represent all needed parameters necessary for [chatwootRepositoryProvider] to successfully provide an instance
/// of [ChatwootRepository].
class RepositoryParameters {
  /// See [ChatwootParameters]
  ChatwootParameters params;

  /// See [ChatwootCallbacks]
  ChatwootCallbacks callbacks;

  RepositoryParameters({required this.params, required this.callbacks});
}
