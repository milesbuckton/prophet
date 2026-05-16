using Encryption.Helpers;

namespace Encryption
{
    internal static class Program
    {
        private static int Main()
        {
            try
            {
                string encryptedMessage = EncryptionHelper.EncryptMessage("COMPUTER OLYMPIAD", "MOPED");

                Console.WriteLine(encryptedMessage);

                return 0;
            }
            catch (Exception ex) when (ex is ArgumentException or FormatException)
            {
                Console.Error.WriteLine($"Invalid input: {ex.Message}");

                return 1;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Unexpected error: {ex.Message}");

                return 1;
            }
        }
    }
}
