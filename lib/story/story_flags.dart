/// Story flags set by dialogue choices.
abstract final class StoryFlags {
  /// Özge sent the first statements: Part 1 is over.
  static const part1Done = 'part1Done';

  /// Orhun told the player that İnanç has the suspect.
  static const orhunDone = 'orhunDone';

  /// İnanç set up the interrogation with Doğa.
  static const inancDone = 'inancDone';

  /// Furkan's interrogation is over and his statement is on Poltel.
  static const furkanStatement = 'furkanStatement';
}
