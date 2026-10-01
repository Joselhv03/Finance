// Modelo plano. No sabe nada de Supabase ni de cómo se consiguen
// estos datos — esa responsabilidad es del Service.
class UserProfile {
  final String email;
  final String username;

  const UserProfile({
    required this.email,
    required this.username,
  });
}