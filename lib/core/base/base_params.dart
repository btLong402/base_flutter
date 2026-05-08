/// Base class for use case parameters
/// Extend this to create type-safe parameters for your use cases
abstract class Params {
  const Params();
}

/// Example usage:
///
/// ```dart
/// class LoginParams extends Params {
///   final String email;
///   final String password;
///
///   const LoginParams({
///     required this.email,
///     required this.password,
///   });
///
///   @override
///   List<Object?> get props => [email, password];
/// }
///
/// class GetUserParams extends Params {
///   final String userId;
///
///   const GetUserParams({required this.userId});
///
///   @override
///   List<Object?> get props => [userId];
/// }
///
/// class PaginationParams extends Params {
///   final int page;
///   final int limit;
///   final String? query;
///
///   const PaginationParams({
///     required this.page,
///     required this.limit,
///     this.query,
///   });
///
///   @override
///   List<Object?> get props => [page, limit, query];
/// }
/// ```
